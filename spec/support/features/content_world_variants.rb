# frozen_string_literal: true

# The optional half of ContentWorld: extra published pages, extra transcripts and
# per-transcript attributes. It is a separate module only because
# Metrics/ModuleLength caps one module at 100 lines; ContentWorld includes it, so
# every example group gets both halves.
module ContentWorldVariants
  # The institution landing page renders this as its hero heading; without it the
  # heading is blank and nothing proves the page rendered the right institution.
  INSTITUTION_INTRODUCTORY_TEXT = 'Listen, transcribe and enrich the stories of New South Wales'

  DEFAULTS = {
    transcript: true, published: true, lines: 3, speakers: 2, collection_published: nil,
    pages: {}, transcript_attributes: {}, extra_transcripts: [], line_overrides: {}
  }.freeze

  private

  def world_options(options)
    unknown = options.keys - DEFAULTS.keys
    raise ArgumentError, "unknown build_content_world option(s): #{unknown.join(', ')}" if unknown.any?

    options = DEFAULTS.merge(options)
    options[:collection_published] = options[:published] if options[:collection_published].nil?
    options
  end

  def build_world_institution
    create(:institution, introductory_text: INSTITUTION_INTRODUCTORY_TEXT)
  end

  def build_public_pages(pages)
    pages.each_with_object({}) do |(page_type, content), built|
      page = Page.find_or_initialize_by(page_type: page_type.to_s)
      page.content = content
      page.published = true
      page.save!
      built[page_type.to_s] = page
    end
  end

  def build_transcript_records(world, options)
    world.transcript_lines = []
    world.speakers = []
    world.transcripts = []
    return unless options[:transcript]

    world.transcript, world.transcript_lines, world.speakers = build_primary_transcript(world, options)
    world.transcripts = [world.transcript] + build_extra_transcripts(world, options)
  end

  def build_primary_transcript(world, options)
    shape = transcript_shape(options).merge(attributes: options[:transcript_attributes])
    build_world_transcript(world.collection, shape)
  end

  def build_extra_transcripts(world, options)
    options[:extra_transcripts].map do |attributes|
      build_world_transcript(world.collection, transcript_shape(options).merge(attributes: attributes)).first
    end
  end

  def transcript_shape(options)
    { published: options[:published], lines: options[:lines], speakers: options[:speakers],
      line_overrides: options[:line_overrides], attributes: {} }
  end

  def build_world_transcript(collection, shape)
    transcript = create(
      :transcript,
      collection: collection,
      project_uid: collection.project_uid,
      lines: shape[:lines],
      publish: shape[:published] ? 1 : 0,
      published_at: shape[:published] ? Time.current : nil,
      **transcript_image_attributes,
      **shape[:attributes]
    )
    speaker_records = build_speakers(transcript, collection, shape[:speakers])
    transcript_lines = build_transcript_lines(transcript, shape[:lines], speaker_records, shape[:line_overrides])

    [transcript, transcript_lines, speaker_records]
  end
end
