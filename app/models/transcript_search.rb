# frozen_string_literal: true

class TranscriptSearch
  attr_reader :transcripts

  def initialize(options)
    options[:page] ||= 1
    options[:per_page] ||= 30
    project = Project.getActive
    per_page = project[:data]['transcriptsPerPage'].to_i if project && project[:data]['transcriptsPerPage']
    sort_order = 'ASC'
    sort_order = 'DESC' if options[:order].present? && options[:order].downcase == 'desc'
    options[:sort_by] ||= 'title'
    sort_by = options[:sort_by]
    sort_by = 'percent_completed' if sort_by.present? && sort_by == 'completeness'
    sort_by = 'title' unless Transcript.sortableFields.include? sort_by

    @transcripts = nil

    # Do a deep search
    if options[:search].present?
      # Build initial transcripts w/ pagination
      @transcripts = TranscriptLine
                     .select('transcripts.*, COALESCE(collections.title, \'\') AS collection_title, transcript_lines.guess_text, transcript_lines.original_text, transcript_lines.start_time, transcript_lines.transcript_id')
                     .joins('INNER JOIN transcripts ON transcripts.id = transcript_lines.transcript_id')
                     .joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id')
                     .joins('INNER JOIN institutions ON institutions.id = collections.institution_id')

      # Do the query
      @transcripts = @transcripts.fuzzy_search(options[:search])

    # else just normal search (title, description)
    else
      # Build initial query w/ pagination
      @transcripts = Transcript
                     .select('transcripts.*, COALESCE(collections.title, \'\') as collection_title, \'\' AS guess_text, \'\' AS original_text, 0 AS start_time')
                     .joins('LEFT OUTER JOIN collections ON collections.id = transcripts.collection_id')
                     .joins('INNER JOIN institutions ON institutions.id = collections.institution_id')
    end

    @transcripts = transcripts.where.not('transcripts.published_at' => nil)
    @transcripts = transcripts.where.not('collections.published_at' => nil)
    @transcripts = transcripts.where(transcripts: { project_uid: ENV['PROJECT_ID'] })

    # Check for collection filter
    @transcripts = transcripts.where(collections: { title: options[:collections] }) if options[:collections].present?

    # check for institution
    @transcripts = transcripts.where(institutions: { slug: options[:institution] }) if options[:institution].present?

    if options[:theme].present?
      @transcripts = transcripts.joins('inner join taggings on taggings.taggable_id = collections.id inner join tags on tags.id =  taggings.tag_id')
      @transcripts = transcripts.where(tags: { name: options[:themes] })
    end

    # Check for sort
    @transcripts = transcripts.order("transcripts.#{sort_by} #{sort_order}")

    # paginate
    @transcripts = @transcripts.paginate(page: options[:page], per_page: options[:per_page])
  end
end
