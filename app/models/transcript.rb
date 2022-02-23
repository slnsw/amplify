class Transcript < ApplicationRecord
  has_paper_trail
  include ImageSizeValidation
  include UidValidationOnUpdate
  include UidValidation

  mount_uploader :image, ImageUploader
  mount_uploader :audio, AudioUploader
  mount_uploader :script, TranscriptUploader

  after_validation :crop_image, on: :update

  def crop_image
    image.recreate_versions! if (!image_changed? && crop_x_changed?)
  end

  include PgSearch
  include Publishable

  multisearchable :against => [:title, :description]
  pg_search_scope :search_default, :against => [:title, :description]
  pg_search_scope :search_by_title, :against => :title

  scope :voicebase_processing_pending, -> { voicebase.where(process_completed_at: nil) }
  scope :not_picked_up_for_voicebase_processing, -> { voicebase.where.not(process_started_at: nil) }
  scope :completed, -> { where(percent_completed: 100) }
  scope :reviewing, -> { where("percent_reviewing > 0 and percent_completed < 100") }
  scope :pending, -> { where("percent_reviewing = 0 and percent_completed < 100") }

  validates :uid, presence: true, uniqueness: true
  validates :vendor, presence: true
  validate :image_size_restriction
  validate :uid_not_changed

  belongs_to :collection, optional: true
  belongs_to :vendor, optional: true
  belongs_to :transcript_status, optional: true
  has_many :transcript_lines, dependent: :destroy
  has_many :transcript_edits, dependent: :destroy
  has_many :transcript_speakers, dependent: :destroy

  attribute :audio_item_url_title, :string, default: "View audio in Library catalogue"
  attribute :image_item_url_title, :string, default: "View image in Library catalogue"

  after_save :process_speech_to_text_for_audio_file

  enum transcript_type: { voicebase: 0, manual: 1, azure: 2 }

  enum process_status: { started: 'started', completed: 'completed', failed: 'failed' }, _prefix: :process

  def self.seconds_per_line
    5
  end

  def publish!
    update_columns(published_at: Time.current, publish: true)
  end

  def unpublish!
    update_columns(published_at: nil, publish: false)
  end

  def transcription_conventions
    collection&.institution&.transcription_conventions
  end

  # speakers getters and setters used to manage the transcript_speakers
  # when creating or editing a transcript
  def speakers
    return "" if transcript_speakers.blank?

    transcript_speakers.includes(:speaker).pluck(:name).join("; ") + "; "
  end

  def speakers=(params)
    return unless valid?

    ActiveRecord::Base.transaction do
      # remove the exist transcript speakers
      transcript_speakers.destroy_all

      # replace the transcript speakers with the new or revised selection
      params.split(';').reject(&:blank?).each do |name|
        transcript_speakers.build(
          speaker_id: Speaker.find_or_create_by(name: name.strip).id,
          collection_id: collection.id,
          project_uid: project_uid
        )
      end
    end
  end

  def to_param
    uid
  end

  def self.getEdited
    Transcript.joins(:transcript_edits).distinct
  end

  def self.getByUserEdited(user_id)
    Transcript
      .joins(:transcript_edits)
      .where(transcript_edits: {user_id: user_id}).distinct
  end

  def self.getForExport(project_uid, collection_uid=false)
    if collection_uid
      Transcript
        .select("transcripts.*, collections.uid AS collection_uid")
        .joins("INNER JOIN collections ON collections.id = transcripts.collection_id")
        .where("transcripts.lines > 0 AND transcripts.project_uid = :project_uid AND transcripts.is_published = :is_published AND collections.uid = :collection_uid", {project_uid: project_uid, is_published: 1, collection_uid: collection_uid})

    else
      Transcript
        .select("transcripts.*, COALESCE(collections.uid, \'\') as collection_uid")
        .joins("LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id")
        .where("transcripts.lines > 0 AND transcripts.project_uid = :project_uid AND transcripts.is_published = :is_published", {project_uid: project_uid, is_published: 1})
    end
  end

  def self.sort_string(sort)
    case sort
    when "title_asc"
      "transcripts.title asc, transcripts.id asc"
    when "title_desc"
      "transcripts.title desc, transcripts.id desc"
    when "percent_completed_desc"
      "transcripts.percent_completed desc, transcripts.percent_edited desc"
    when "percent_completed_asc"
      "transcripts.percent_completed asc, transcripts.percent_edited"
    when "duration_asc"
      "transcripts.duration asc, transcripts.id"
    when "duration_desc"
      "transcripts.duration desc, transcripts.id desc"
    when "collection_id_asc"
      "collections.title asc, transcripts.id"
    else
      nil
    end
  end

  def self.get_for_home_page(params)
    sort = params[:sort_by].to_s

    query = Transcript.includes(collection: [:institution]).
      select('transcripts.*, COALESCE(collections.title, \'\') as collection_title').
      joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id').
      joins('LEFT OUTER JOIN institutions ON institutions.id = collections.institution_id').
      where("transcripts.lines > 0 AND transcripts.project_uid = :project_uid AND transcripts.published_at is NOT NULL and collections.published_at is NOT NULL", {project_uid: ENV['PROJECT_ID']})

    # scope by collection
    query = query.where("collections.title in (?)", params[:collections]) if params[:collections].present?

    # scope by institution
    query = query.where("institutions.slug = '#{params[:institution]}'") if params[:institution].present?

    # scope for theme
    # since the theme is coming from the dropdown, we can use it as is
    if params[:themes].present?
      query = query.joins('inner join taggings on taggings.taggable_id = collections.id inner join tags on tags.id =  taggings.tag_id')
      query = query.where("tags.name in (?)", params[:themes])
    end

    # search text
    if params[:search].present?
      query = query.where(
        "transcripts.title ILIKE :search or transcripts.description ILIKE :search", search: "%#{params[:search]}%"
      )
    end

    if sort.match(/title/i)
      arr = query.sort_by { |e| e.title.gsub(/\d+/) { |num| "#{num.length} #{num}" } }
      sort == "title_asc" ? arr : arr.reverse
    else
      order = sort_string(params[:sort_by])
      # if the order is nil, that means random
      order ? query.order(order) : randomize_list(query)
    end
  end

  def self.randomize_list(query)
    query.shuffle
  end

  def self.getForHomepage(page=1, options={})
    page ||= 1
    str_order = sort_string(options)

    project = Project.getActive

    per_page = 500
    per_page = project[:data]["transcriptsPerPage"].to_i if project && project[:data]["transcriptsPerPage"]

    Rails.cache.fetch("#{ENV['PROJECT_ID']}/transcripts/#{page}/#{per_page}/#{options[:order]}", expires_in: 10.minutes) do
      query = Transcript
        .select('transcripts.*, COALESCE(collections.title, \'\') as collection_title')
        .joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id')
        .where("transcripts.lines > 0 AND transcripts.project_uid = :project_uid AND transcripts.is_published = :is_published", {project_uid: ENV['PROJECT_ID'], is_published: 1})
        .paginate(:page => page, :per_page => per_page)
      query =  query.order(str_order) if str_order
      query
    end
  end

  def self.getForDownloadByVendor(vendor_uid, project_uid)
    vendor = Vendor.find_by_uid(vendor_uid)
    Transcript.joins(:collection)
      .where("transcripts.vendor_id = :vendor_id AND transcripts.lines <= 0 AND collections.vendor_identifier != :empty AND transcripts.vendor_identifier != :empty AND transcripts.project_uid = :project_uid",
      {vendor_id: vendor[:id], empty: "", project_uid: project_uid})
  end

  def self.getUpdatedAfter(date, page=1, options={})
    page ||= 1
    project = Project.getActive
    per_page = 500
    per_page = project[:data]["transcriptsPerPage"].to_i if project && project[:data]["transcriptsPerPage"]

    Transcript
      .select('transcripts.*, COALESCE(collections.uid, \'\') AS collection_uid')
      .joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id')
      .where("transcripts.lines > 0 AND transcripts.project_uid = :project_uid AND transcripts.is_published = :is_published AND transcripts.updated_at > :update_after", {project_uid: ENV['PROJECT_ID'], is_published: 1, update_after: date})
      .distinct
      .order("updated_at DESC")
      .paginate(:page => page, :per_page => per_page)
  end

  def self.sortableFields
    return ["percent_completed", "duration", "title", "collection_id"]
  end

  # Incrementally update transcript stats based on line delta
  def delta(line_status_id_before, line_status_id_after, statuses=nil)
    return if lines <= 0

    statuses ||= TranscriptLineStatus.allCached

    # initialize stats
    changed = false
    new_lines_completed = lines_completed
    new_lines_edited = lines_edited
    new_lines_reviewing = lines_reviewing
    new_percent_completed = percent_completed
    new_percent_edited = percent_edited
    new_percent_reviewing = percent_reviewing

    # retrieve statuses
    before_status = statuses.find{|s| s[:id]==line_status_id_before}
    after_status = statuses.find{|s| s[:id]==line_status_id_after}

    # Case: initialized before, something else after, increment lines edited
    if (!before_status || before_status.name!="editing") && after_status && after_status.name=="editing"
      new_lines_edited += 1
      changed = true

    # Case: edited before, not edited after
    elsif before_status && before_status.name=="editing" && (!after_status || after_status.name!="editing")
      new_lines_edited -= 1
      changed = true
    end

    # Case: not completed before, completed after
    if (!before_status || before_status.name!="completed") && after_status && after_status.name=="completed"
      new_lines_completed += 1
      changed = true

    # Case: completed before, not completed after
    elsif before_status && before_status.name=="completed" && (!after_status || after_status.name!="completed")
      new_lines_completed -= 1
      changed = true
    end

    # Case: not reviewing before, reviewing after
    if (!before_status || before_status.name!="reviewing") && after_status && after_status.name=="reviewing"
      new_lines_reviewing += 1
      changed = true

    # Case: reviewing before, not reviewing after
    elsif before_status && before_status.name=="reviewing" && (!after_status || after_status.name!="reviewing")
      new_lines_reviewing -= 1
      changed = true
    end

    # Update
    if changed
      new_percent_edited = (1.0 * new_lines_edited / lines * 100).round.to_i
      new_percent_completed = (1.0 * new_lines_completed / lines * 100).round.to_i
      new_percent_reviewing = (1.0 * new_lines_reviewing / lines * 100).round.to_i

      update_attributes(lines_edited: new_lines_edited, lines_completed: new_lines_completed, lines_reviewing: new_lines_reviewing, percent_edited: new_percent_edited, percent_completed: new_percent_completed, percent_reviewing: new_percent_reviewing)
    end
  end

  def getUsersContributedCount(edits=[])
    if edits.length > 0
      edits.collect {|edit|
        if edit.user_id > 0
          edit.user_id.to_s
        else
          edit.session_id
        end
      }.uniq.length
    else
      TranscriptEdit
        .select("CASE WHEN user_id=0 THEN session_id ELSE to_char(user_id, '999999999999999') END")
        .where(transcript_id: id).distinct.count
    end
  end

  def loadFromWebVTT(webvtt)
    transcript_lines = _getLinesFromWebVTT(webvtt)

    if transcript_lines.length > 0
      # remove existing lines
      TranscriptLine.destroy_all(:transcript_id => id)

      # create the lines
      TranscriptLine.create(transcript_lines)

      # update transcript
      transcript_status = TranscriptStatus.find_by_name("transcript_downloaded")
      transcript_duration = _getDurationFromWebVTT(webvtt)

      update_attributes(lines: transcript_lines.length, transcript_status_id: transcript_status[:id], duration: transcript_duration, transcript_retrieved_at: DateTime.now)
      puts "Created #{transcript_lines.length} lines from transcript #{uid}"
    end

    # Delete existing speakers
    speaker_ids = TranscriptSpeaker.select("speaker_id").where(:transcript_id => id)
    speaker_ids = speaker_ids.map {|i| i.speaker_id }
    Speaker.where(id: speaker_ids).delete_all
    TranscriptSpeaker.destroy_all(:transcript_id => id)

    # Check for speakers
    _getSpeakersWebVTT(webvtt)
  end

  def recalculate
    return if lines <= 0

    # Find all the edited lines
    edited_lines = TranscriptLine.getEditedByTranscriptId(id)

    # And all the completed/reviewing lines
    statuses = TranscriptLineStatus.allCached
    completed_status = statuses.find { |s| s[:name] == "completed" }
    completed_lines = edited_lines.select { |s| s[:transcript_line_status_id] == completed_status[:id] }
    reviewing_status = statuses.find { |s| s[:name] == "reviewing" }
    reviewing_lines = edited_lines.select { |s| s[:transcript_line_status_id] == reviewing_status[:id] }

    # Calculate
    _lines_edited = edited_lines.length
    _lines_completed = completed_lines.length
    _lines_reviewing = reviewing_lines.length
    _percent_edited = (1.0 * _lines_edited / lines * 100).round.to_i
    _percent_completed = (1.0 * _lines_completed / lines * 100).round.to_i
    _percent_reviewing = (1.0 * _lines_reviewing / lines * 100).round.to_i

    # Get user count
    _users_contributed = getUsersContributedCount

    # Update
    update_attributes(
      lines_edited: _lines_edited, lines_completed: _lines_completed, lines_reviewing: _lines_reviewing,
      percent_edited: _percent_edited, percent_completed: _percent_completed, percent_reviewing: _percent_reviewing,
      users_contributed: _users_contributed
    )
  end

  def self.search(options)
    options[:page] ||= 1
    project = Project.getActive
    per_page = 500
    per_page = project[:data]["transcriptsPerPage"].to_i if project && project[:data]["transcriptsPerPage"]
    sort_order = "ASC"
    sort_order = "DESC" if options[:order].present? && options[:order].downcase=="desc"
    options[:sort_by] ||= "title"
    sort_by = options[:sort_by]
    sort_by = "percent_completed" if sort_by.present? && sort_by=="completeness"
    sort_by = "title" if !Transcript.sortableFields().include? sort_by

    transcripts = nil

    # Do a deep search
    if options[:q].present?
      # Build initial query w/ pagination
      transcripts = TranscriptLine
        .select('transcripts.*, COALESCE(collections.title, \'\') AS collection_title, transcript_lines.guess_text, transcript_lines.original_text, transcript_lines.start_time, transcript_lines.transcript_id')
        .joins('INNER JOIN transcripts ON transcripts.id = transcript_lines.transcript_id')
        .joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id')
        .joins('INNER JOIN institutions ON institutions.id = collections.institution_id')

      # Do the query
      transcripts = transcripts.search_by_all_text(options[:q])

    # else just normal search (title, description)
    else
      # Build initial query w/ pagination
      transcripts = Transcript
        .select('transcripts.*, COALESCE(collections.title, \'\') as collection_title, \'\' AS guess_text, \'\' AS original_text, 0 AS start_time')
        .joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id')
        .joins('INNER JOIN institutions ON institutions.id = collections.institution_id')

      # Check for query
      transcripts = transcripts.search_default(options[:q]) if options[:q].present? && !options[:q].blank?
    end


    transcripts = transcripts.where("transcripts.published_at IS NOT NULL")
    transcripts = transcripts.where("collections.published_at IS NOT NULL")
    # Paginate
    transcripts = transcripts.where("transcripts.project_uid = :project_uid", {project_uid: ENV['PROJECT_ID']}).paginate(:page => options[:page], :per_page => per_page)

    # Check for collection filter
    transcripts = transcripts.where("transcripts.collection_id IN (:collection_id)", {collection_id: options[:collection_id]}) if options[:collection_id].present?

    # check for institution
    transcripts = transcripts.where("institutions.id = :id", {id: options[:institution_id].to_i}) if options[:institution_id].present?

    if options[:theme].present?
      transcripts = transcripts.joins('inner join taggings on taggings.taggable_id = collections.id inner join tags on tags.id =  taggings.tag_id')
      transcripts = transcripts.where("tags.name in (?)", options[:theme])
    end


    # Check for sort
    transcripts.order("transcripts.#{sort_by} #{sort_order}")
  end

  def updateUsersContributed(edits=[])
    _users_contributed = getUsersContributedCount(edits)

    if _users_contributed != users_contributed
      update_attributes(users_contributed: _users_contributed)
    end
  end

  def _getDurationFromWebVTT(webvtt)
    duration = 0
    unless webvtt.cues.empty?
      duration = (webvtt.cues.last.end_in_sec * 1000).to_i
    end
    duration
  end

  def _getLinesFromWebVTT(webvtt)
    transcript_lines = []
    webvtt.cues.each_with_index do |cue, i|
      # Remove speakers from lines
      text = cue.text.gsub(/^<v [^>]*>[ ]*/, "")
      # Add to lines
      transcript_lines << {
        transcript_id: id,
        start_time: (cue.start_in_sec * 1000).to_i,
        end_time: (cue.end_in_sec * 1000).to_i,
        original_text: text,
        sequence: i
      }
    end
    transcript_lines
  end

  def _getSpeakersWebVTT(webvtt)
    speakers = []
    webvtt.cues.each_with_index do |cue, i|
      # Retrieve speaker from lines
      speakerMatch = /^<v ([^>]*)>[ ]*.*/.match(cue.text)
      unless speakerMatch.nil? || speakerMatch.captures.empty?
        speakerName = speakerMatch.captures.first
        speaker = speakers.find{|s| s[:name]==speakerName}

        # New speaker
        if speaker.nil?
          speaker = Speaker.create(name: speakerName)
          # Create transcript speaker
          TranscriptSpeaker.create(speaker_id: speaker.id, transcript_id: id, collection_id: collection_id, project_uid: project_uid)
          speakers << speaker
        end

        # Retrieve and update line
        line = TranscriptLine.getByTranscriptSequence(id, i)
        if line && speaker
          line.update(speaker_id: speaker.id)
        end
      end
    end
  end

  def process_speech_to_text_for_audio_file
    # no change? no process
    return unless audio.identifier && saved_change_to_attribute?(:audio) && !process_started?

    Azure::SpeechToTextJob.perform_later(id) if azure?
  end

  def disk_usage
    Rails.cache.fetch("Transcript:disk_usage:#{id}", expires_in: 23.hours) do
      {
        image: image.size,
        audio: audio.size,
        script: script.size
      }
    end
  end

  # If the image has a cropped version we display it, otherwise we display the original image.
  def image_cropped_thumb_url
    crop_x.present? ? image_url(:cropped_thumb) : (image_url || collection.image_url)
  end
end
