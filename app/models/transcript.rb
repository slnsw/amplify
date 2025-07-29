# frozen_string_literal: true

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
    image.recreate_versions! if !image_changed? && crop_x_changed?
  end

  include PgSearch
  include Publishable

  multisearchable against: %i[title description]
  pg_search_scope :search_default, against: %i[title description]
  pg_search_scope :search_by_title, against: :title

  # TODO: Convert to integer-based enum
  enum :transcript_type, { voicebase: 0, manual: 1, azure: 2 }

  enum :process_status, { started: 'started', completed: 'completed', failed: 'failed' }, prefix: :process

  scope :voicebase_processing_pending, -> { voicebase.where(process_completed_at: nil) }
  scope :not_picked_up_for_voicebase_processing, -> { voicebase.where.not(process_started_at: nil) }
  scope :completed, -> { where(percent_completed: 100) }
  scope :reviewing, -> { where('percent_reviewing > 0 and percent_completed < 100') }
  scope :pending, -> { where('percent_reviewing = 0 and percent_completed < 100') }

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

  attribute :audio_item_url_title, :string, default: 'View audio in Library catalogue'
  attribute :image_item_url_title, :string, default: 'View image in Library catalogue'

  after_save :process_speech_to_text_for_audio_file

  def self.seconds_per_line
    5
  end

  def publish!
    update!(published_at: Time.current, publish: true)
  end

  def unpublish!
    update!(published_at: nil, publish: false)
  end

  def transcription_conventions
    collection&.institution&.transcription_conventions
  end

  # speakers getters and setters used to manage the transcript_speakers
  # when creating or editing a transcript
  def speakers
    return '' if transcript_speakers.blank?

    "#{transcript_speakers.includes(:speaker).pluck(:name).join('; ')}; "
  end

  def speakers=(params)
    return unless valid?

    ActiveRecord::Base.transaction do
      # remove the exist transcript speakers
      transcript_speakers.destroy_all

      # replace the transcript speakers with the new or revised selection
      params.split(';').compact_blank.each do |name|
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

  def self.edited
    Transcript.joins(:transcript_edits).distinct
  end

  def self.get_by_user_edited(user_id)
    Transcript
      .joins(:transcript_edits)
      .where(transcript_edits: { user_id: user_id }).distinct
  end

  def self.get_for_export(project_uid, collection_uid: false)
    if collection_uid
      get_for_export_with_collection(project_uid, collection_uid)
    else
      get_for_export_without_collection(project_uid)
    end
  end

  def self.get_for_export_with_collection(project_uid, collection_uid)
    Transcript
      .select('transcripts.*, collections.uid AS collection_uid')
      .joins('INNER JOIN collections ON collections.id = transcripts.collection_id')
      .where(
        'transcripts.lines > 0 AND transcripts.project_uid = :project_uid AND ' \
        'transcripts.is_published = :is_published AND collections.uid = :collection_uid',
        { project_uid: project_uid, is_published: 1, collection_uid: collection_uid }
      )
  end

  def self.get_for_export_without_collection(project_uid)
    Transcript
      .select("transcripts.*, COALESCE(collections.uid, '') as collection_uid")
      .joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id')
      .where(
        'transcripts.lines > 0 AND transcripts.project_uid = :project_uid AND ' \
        'transcripts.is_published = :is_published',
        { project_uid: project_uid, is_published: 1 }
      )
  end

  def self.sort_string(sort)
    sort_options = {
      'title_asc' => 'transcripts.title asc, transcripts.id asc',
      'title_desc' => 'transcripts.title desc, transcripts.id desc',
      'percent_completed_desc' => 'transcripts.percent_completed desc, transcripts.percent_edited desc',
      'percent_completed_asc' => 'transcripts.percent_completed asc, transcripts.percent_edited',
      'duration_asc' => 'transcripts.duration asc, transcripts.id',
      'duration_desc' => 'transcripts.duration desc, transcripts.id desc',
      'collection_id_asc' => 'collections.title asc, transcripts.id'
    }
    sort_options[sort]
  end

  def self.get_for_home_page(params)
    sort = params[:sort_by].to_s
    query = build_base_query_for_home_page
    query = apply_filters_to_query(query, params)
    apply_sorting_to_query(query, sort, params)
  end

  def self.build_base_query_for_home_page
    Transcript.includes(collection: [:institution])
              .select('transcripts.*, COALESCE(collections.title, \'\') as collection_title')
              .joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id')
              .joins('LEFT OUTER JOIN institutions ON institutions.id = collections.institution_id')
              .where(
                'transcripts.lines > 0 AND transcripts.project_uid = :project_uid AND ' \
                'transcripts.published_at is NOT NULL and collections.published_at is NOT NULL',
                { project_uid: ENV.fetch('PROJECT_ID', nil) }
              )
              .where(institutions: { hidden: false })
  end

  def self.apply_filters_to_query(query, params)
    # scope by collection
    query = query.where(collections: { title: params[:collections] }) if params[:collections].present?

    # scope by institution
    query = query.where(institutions: { slug: params[:institution] }) if params[:institution].present?

    # scope for theme
    query = apply_theme_filter(query, params[:themes]) if params[:themes].present?

    # search text
    query = apply_search_filter(query, params[:search]) if params[:search].present?

    query
  end

  def self.apply_theme_filter(query, themes)
    query.joins(
      'inner join taggings on taggings.taggable_id = collections.id inner join tags on tags.id =  taggings.tag_id'
    ).where(tags: { name: themes })
  end

  def self.apply_search_filter(query, search_term)
    query.where(
      'transcripts.title ILIKE :search or transcripts.description ILIKE :search',
      search: "%#{search_term}%"
    )
  end

  def self.apply_sorting_to_query(query, sort, params)
    if sort.match(/title/i)
      arr = query.sort_by { |e| e.title.gsub(/\d+/) { |num| "#{num.length} #{num}" } }
      sort == 'title_asc' ? arr : arr.reverse
    else
      order = sort_string(params[:sort_by])
      # if the order is nil, that means random
      order ? query.order(order) : randomize_list(query)
    end
  end

  def self.randomize_list(query)
    query.shuffle
  end

  def self.get_for_homepage(page = 1, options = {})
    page ||= 1
    str_order = sort_string(options)

    project = Project.getActive

    per_page = 500
    per_page = project[:data]['transcriptsPerPage'].to_i if project && project[:data]['transcriptsPerPage']

    Rails.cache.fetch("#{ENV.fetch('PROJECT_ID', nil)}/transcripts/#{page}/#{per_page}/#{options[:order]}",
                      expires_in: 10.minutes) do
      query = Transcript
              .select('transcripts.*, COALESCE(collections.title, \'\') as collection_title')
              .joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id')
              .where(
                'transcripts.lines > 0 AND transcripts.project_uid = :project_uid AND ' \
                'transcripts.is_published = :is_published',
                { project_uid: ENV.fetch('PROJECT_ID', nil), is_published: 1 }
              )
              .paginate(page: page, per_page: per_page)
      query = query.order(str_order) if str_order
      query
    end
  end

  def self.get_for_download_by_vendor(vendor_uid, project_uid)
    vendor = Vendor.find_by(uid: vendor_uid)
    Transcript.joins(:collection)
              .where(
                'transcripts.vendor_id = :vendor_id AND transcripts.lines <= 0 AND ' \
                'collections.vendor_identifier != :empty AND transcripts.vendor_identifier != :empty AND ' \
                'transcripts.project_uid = :project_uid',
                { vendor_id: vendor[:id], empty: '', project_uid: project_uid }
              )
  end

  def self.get_for_update_by_vendor(vendor_uid, project_uid)
    vendor = Vendor.find_by(uid: vendor_uid)
    Transcript.joins(:collection)
              .where(
                'transcripts.vendor_id = :vendor_id AND collections.vendor_id = :vendor_id AND ' \
                'collections.vendor_identifier != :empty AND transcripts.vendor_identifier != :empty AND ' \
                'transcripts.project_uid = :project_uid',
                { vendor_id: vendor[:id], empty: '', project_uid: project_uid }
              )
  end

  def self.get_for_upload_by_vendor(vendor_uid, project_uid)
    vendor = Vendor.find_by(uid: vendor_uid)
    Transcript.joins(:collection)
              .where(
                'transcripts.vendor_id = :vendor_id AND transcripts.vendor_identifier = :empty AND ' \
                'collections.vendor_id = :vendor_id AND transcripts.lines <= 0 AND ' \
                'collections.vendor_identifier != :empty AND transcripts.project_uid = :project_uid',
                { vendor_id: vendor[:id], empty: '', project_uid: project_uid }
              )
  end

  def self.get_updated_after(date, page = 1, _options = {})
    page ||= 1
    project = Project.getActive
    per_page = 500
    per_page = project[:data]['transcriptsPerPage'].to_i if project && project[:data]['transcriptsPerPage']

    Transcript
      .select('transcripts.*, COALESCE(collections.uid, \'\') AS collection_uid')
      .joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id')
      .where(
        'transcripts.lines > 0 AND transcripts.project_uid = :project_uid AND ' \
        'transcripts.is_published = :is_published AND transcripts.updated_at > :update_after',
        { project_uid: ENV.fetch('PROJECT_ID', nil), is_published: 1, update_after: date }
      )
      .distinct
      .order('updated_at DESC')
      .paginate(page: page, per_page: per_page)
  end

  def self.sortable_fields
    %w[percent_completed duration title collection_id]
  end

  # Incrementally update transcript stats based on line delta
  def delta(line_status_id_before, line_status_id_after, statuses = nil)
    return if lines <= 0

    statuses ||= TranscriptLineStatus.allCached

    # initialize stats
    changed = false
    new_lines_completed = lines_completed
    new_lines_edited = lines_edited
    new_lines_reviewing = lines_reviewing
    percent_completed
    percent_edited
    percent_reviewing

    # retrieve statuses
    before_status = statuses.find { |s| s[:id] == line_status_id_before }
    after_status = statuses.find { |s| s[:id] == line_status_id_after }

    # Case: initialized before, something else after, increment lines edited
    if (!before_status || before_status.name != 'editing') && after_status && after_status.name == 'editing'
      new_lines_edited += 1
      changed = true

    # Case: edited before, not edited after
    elsif before_status && before_status.name == 'editing' && (!after_status || after_status.name != 'editing')
      new_lines_edited -= 1
      changed = true
    end

    # Case: not completed before, completed after
    if (!before_status || before_status.name != 'completed') && after_status && after_status.name == 'completed'
      new_lines_completed += 1
      changed = true

    # Case: completed before, not completed after
    elsif before_status && before_status.name == 'completed' && (!after_status || after_status.name != 'completed')
      new_lines_completed -= 1
      changed = true
    end

    # Case: not reviewing before, reviewing after
    if (!before_status || before_status.name != 'reviewing') && after_status && after_status.name == 'reviewing'
      new_lines_reviewing += 1
      changed = true

    # Case: reviewing before, not reviewing after
    elsif before_status && before_status.name == 'reviewing' && (!after_status || after_status.name != 'reviewing')
      new_lines_reviewing -= 1
      changed = true
    end

    # Update
    return unless changed

    new_percent_edited = (1.0 * new_lines_edited / lines * 100).round.to_i
    new_percent_completed = (1.0 * new_lines_completed / lines * 100).round.to_i
    new_percent_reviewing = (1.0 * new_lines_reviewing / lines * 100).round.to_i

    update(
      lines_edited: new_lines_edited, lines_completed: new_lines_completed,
      lines_reviewing: new_lines_reviewing, percent_edited: new_percent_edited,
      percent_completed: new_percent_completed, percent_reviewing: new_percent_reviewing
    )
  end

  def get_users_contributed_count(edits = [])
    if edits.length.positive?
      edits.collect do |edit|
        if edit.user_id.positive?
          edit.user_id.to_s
        else
          edit.session_id
        end
      end.uniq.length
    else
      TranscriptEdit
        .select("CASE WHEN user_id=0 THEN session_id ELSE to_char(user_id, '999999999999999') END")
        .where(transcript_id: id).distinct.count
    end
  end

  def load_from_hash(contents)
    transcript_lines = _get_lines_from_hash(contents)

    if transcript_lines.length.positive?
      process_transcript_lines(transcript_lines, contents)
    elsif contents['audio_files']&.length&.positive?
      handle_processing_transcript(contents)
    else
      handle_no_audio_recognized
    end
  end

  def process_transcript_lines(transcript_lines, contents)
    # remove existing lines
    TranscriptLine.where(transcript_id: id).destroy_all

    # create the lines
    TranscriptLine.create(transcript_lines)

    # update transcript
    transcript_status = TranscriptStatus.find_by(name: 'transcript_downloaded')
    transcript_duration = _get_duration_from_hash(contents)
    vendor_audio_urls = _get_audio_urls_from_hash(contents)

    update(lines: transcript_lines.length, transcript_status_id: transcript_status[:id],
           duration: transcript_duration, vendor_audio_urls: vendor_audio_urls,
           transcript_retrieved_at: DateTime.now)
    Rails.logger.debug { "Created #{transcript_lines.length} lines from transcript #{uid}" }
  end

  def handle_processing_transcript(contents)
    transcript_status = TranscriptStatus.find_by(name: 'transcript_processing')
    update(transcript_status_id: transcript_status[:id])
    Rails.logger.debug do
      "Transcript #{uid} still processing with status: #{contents['audio_files'][0]['current_status']}"
    end
  end

  def handle_no_audio_recognized
    Rails.logger.debug { "Transcript #{uid} still processing (no audio file found)" }
  end

  def load_from_webvtt(webvtt)
    transcript_lines = _get_lines_from_webvtt(webvtt)

    if transcript_lines.length.positive?
      # remove existing lines
      TranscriptLine.where(transcript_id: id).destroy_all

      # create the lines
      TranscriptLine.create(transcript_lines)

      # update transcript
      transcript_status = TranscriptStatus.find_by(name: 'transcript_downloaded')
      transcript_duration = _get_duration_from_webvtt(webvtt)

      update(lines: transcript_lines.length, transcript_status_id: transcript_status[:id],
             duration: transcript_duration, transcript_retrieved_at: DateTime.now)
      Rails.logger.debug { "Created #{transcript_lines.length} lines from transcript #{uid}" }
    end

    # Delete existing speakers
    speaker_ids = TranscriptSpeaker.select('speaker_id').where(transcript_id: id)
    speaker_ids = speaker_ids.map(&:speaker_id)
    Speaker.where(id: speaker_ids).delete_all
    TranscriptSpeaker.where(transcript_id: id).destroy_all

    # Check for speakers
    _get_speakers_webvtt(webvtt)
  end

  def recalculate
    return if lines <= 0

    edited_lines = TranscriptLine.getEditedByTranscriptId(id)
    statuses = TranscriptLineStatus.allCached

    line_counts = calculate_line_counts(edited_lines, statuses)
    users_contributed_count = get_users_contributed_count

    update_transcript_statistics(line_counts, users_contributed_count)
  end

  def calculate_line_counts(edited_lines, statuses)
    completed_status = statuses.find { |s| s[:name] == 'completed' }
    reviewing_status = statuses.find { |s| s[:name] == 'reviewing' }

    completed_lines = edited_lines.select { |s| s[:transcript_line_status_id] == completed_status[:id] }
    reviewing_lines = edited_lines.select { |s| s[:transcript_line_status_id] == reviewing_status[:id] }

    {
      edited: edited_lines.length,
      completed: completed_lines.length,
      reviewing: reviewing_lines.length
    }
  end

  def update_transcript_statistics(line_counts, users_contributed_count)
    percent_edited_count = (1.0 * line_counts[:edited] / lines * 100).round.to_i
    percent_completed_count = (1.0 * line_counts[:completed] / lines * 100).round.to_i
    percent_reviewing_count = (1.0 * line_counts[:reviewing] / lines * 100).round.to_i

    update(
      lines_edited: line_counts[:edited], lines_completed: line_counts[:completed],
      lines_reviewing: line_counts[:reviewing], percent_edited: percent_edited_count,
      percent_completed: percent_completed_count, percent_reviewing: percent_reviewing_count,
      users_contributed: users_contributed_count
    )
  end

  def self.search(options)
    options[:page] ||= 1
    project = Project.getActive
    per_page = calculate_per_page(project)
    sort_order, sort_by = determine_sort_options(options)

    transcripts = build_search_query(options)
    transcripts = apply_search_filters(transcripts, options, per_page)
    transcripts.order("transcripts.#{sort_by} #{sort_order}")
  end

  def self.calculate_per_page(project)
    per_page = 500
    per_page = project[:data]['transcriptsPerPage'].to_i if project && project[:data]['transcriptsPerPage']
    per_page
  end

  def self.determine_sort_options(options)
    sort_order = 'ASC'
    sort_order = 'DESC' if options[:order].present? && options[:order].downcase == 'desc'
    options[:sort_by] ||= 'title'
    sort_by = options[:sort_by]
    sort_by = 'percent_completed' if sort_by.present? && sort_by == 'completeness'
    sort_by = 'title' unless Transcript.sortable_fields.include? sort_by
    [sort_order, sort_by]
  end

  def self.build_search_query(options)
    if options[:q].present?
      build_deep_search_query(options)
    else
      build_normal_search_query(options)
    end
  end

  def self.build_deep_search_query(options)
    transcripts = TranscriptLine
                  .select(
                    'transcripts.*, COALESCE(collections.title, \'\') AS collection_title, ' \
                    'transcript_lines.guess_text, transcript_lines.original_text, ' \
                    'transcript_lines.start_time, transcript_lines.transcript_id'
                  )
                  .joins('INNER JOIN transcripts ON transcripts.id = transcript_lines.transcript_id')
                  .joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id')
                  .joins('INNER JOIN institutions ON institutions.id = collections.institution_id')
    transcripts.search_by_all_text(options[:q])
  end

  def self.build_normal_search_query(options)
    transcripts = Transcript
                  .select(
                    'transcripts.*, COALESCE(collections.title, \'\') as collection_title, ' \
                    '\'\' AS guess_text, \'\' AS original_text, 0 AS start_time'
                  )
                  .joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id')
                  .joins('INNER JOIN institutions ON institutions.id = collections.institution_id')

    transcripts = transcripts.search_default(options[:q]) if options[:q].present?
    transcripts
  end

  def self.apply_search_filters(transcripts, options, per_page)
    transcripts = transcripts.where.not(transcripts: { published_at: nil })
    transcripts = transcripts.where.not(collections: { published_at: nil })
    transcripts = transcripts.where(transcripts: { project_uid: ENV.fetch('PROJECT_ID', nil) })
                             .paginate(page: options[:page], per_page: per_page)

    # Apply optional filters
    transcripts = apply_collection_filter(transcripts, options[:collection_id]) if options[:collection_id].present?
    transcripts = apply_institution_filter(transcripts, options[:institution_id]) if options[:institution_id].present?
    transcripts = apply_theme_search_filter(transcripts, options[:theme]) if options[:theme].present?
    transcripts
  end

  def self.apply_collection_filter(transcripts, collection_id)
    transcripts.where(transcripts: { collection_id: collection_id })
  end

  def self.apply_institution_filter(transcripts, institution_id)
    transcripts.where(institutions: { id: institution_id.to_i })
  end

  def self.apply_theme_search_filter(transcripts, theme)
    transcripts.joins(
      'inner join taggings on taggings.taggable_id = collections.id ' \
      'inner join tags on tags.id = taggings.tag_id'
    ).where(tags: { name: theme })
  end

  def update_from_hash(contents)
    vendor_audio_urls = _get_audio_urls_from_hash(contents)
    update(vendor_audio_urls: vendor_audio_urls)
  end

  def update_users_contributed(edits = [])
    users_contributed_count = get_users_contributed_count(edits)

    return unless users_contributed_count != users_contributed

    update(users_contributed: users_contributed_count)
  end

  def _get_audio_urls_from_hash(contents)
    audio_urls = []
    audio_urls = contents['audio_files'][0]['url'].to_json if contents['audio_files']&.length&.positive?
    audio_urls
  end

  def _get_duration_from_hash(contents)
    audio_duration = 0
    if contents['audio_files']&.length&.positive? && contents['audio_files'][0]['duration']
      audio_duration = contents['audio_files'][0]['duration'].to_i
    end
    audio_duration
  end

  def _get_duration_from_webvtt(webvtt)
    duration = 0
    duration = (webvtt.cues.last.end_in_sec * 1000).to_i unless webvtt.cues.empty?
    duration
  end

  def _get_lines_from_hash(contents)
    transcript_lines = []
    return transcript_lines unless valid_audio_content?(contents)

    raw_lines = contents['audio_files'][0]['transcript']['parts']
    build_transcript_lines_from_raw(raw_lines)
  end

  def valid_audio_content?(contents)
    contents['audio_files']&.length&.positive? &&
      contents['audio_files'][0]['transcript'] &&
      contents['audio_files'][0]['transcript']['parts']&.length&.positive?
  end

  def build_transcript_lines_from_raw(raw_lines)
    transcript_lines = []
    raw_lines.each_with_index do |raw_line, i|
      transcript_lines << {
        transcript_id: id,
        start_time: (raw_line['start_time'].to_f * 1000).to_i,
        end_time: (raw_line['end_time'].to_f * 1000).to_i,
        original_text: raw_line['text'],
        sequence: i,
        speaker_id: raw_line['speaker_id'].to_i
      }
    end
    transcript_lines
  end

  def _get_lines_from_webvtt(webvtt)
    transcript_lines = []
    webvtt.cues.each_with_index do |cue, i|
      # Remove speakers from lines
      text = cue.text.gsub(/^<v [^>]*>[ ]*/, '')
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

  def _get_speakers_webvtt(webvtt)
    speakers = []
    webvtt.cues.each_with_index do |cue, i|
      process_speaker_from_cue(cue, i, speakers)
    end
  end

  def process_speaker_from_cue(cue, sequence, speakers)
    speaker_match = /^<v ([^>]*)>[ ]*.*/.match(cue.text)
    return if speaker_match.nil? || speaker_match.captures.empty?

    speaker_name = speaker_match.captures.first
    speaker = find_or_create_speaker(speaker_name, speakers)
    update_line_with_speaker(sequence, speaker)
  end

  def find_or_create_speaker(speaker_name, speakers)
    speaker = speakers.find { |s| s[:name] == speaker_name }

    if speaker.nil?
      speaker = Speaker.create(name: speaker_name)
      create_transcript_speaker(speaker)
      speakers << speaker
    end

    speaker
  end

  def create_transcript_speaker(speaker)
    TranscriptSpeaker.create(
      speaker_id: speaker.id, transcript_id: id,
      collection_id: collection_id, project_uid: project_uid
    )
  end

  def update_line_with_speaker(sequence, speaker)
    line = TranscriptLine.getByTranscriptSequence(id, sequence)
    line.update(speaker_id: speaker.id) if line && speaker
  end

  def process_speech_to_text_for_audio_file
    # no change? no process
    return unless audio.identifier && saved_change_to_attribute?(:audio) && !process_started?

    Azure::SpeechToTextJob.perform_later(id) if azure?
  end

  # Public: Returns the disk usage for this transcript.
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
    return nil if image_url.blank?

    crop_x.present? ? image_url(:cropped_thumb) : (image_url || collection.image_url)
  end
end
