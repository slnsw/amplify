# frozen_string_literal: true

require_relative 'content_world_variants'

# Builds the content records the public pages read, so feature specs don't each
# repeat institution/collection/transcript/page setup.
#
#   world = build_content_world
#   visit root_path
#   expect(page).to have_text(world.transcript.title)
#
# Plan signature plus documented extras:
#
#   build_content_world(transcript: true, published: true, lines: 3, speakers: 2)
#
#   * transcript:            false builds only the institution/collection/page shell
#                            (`world.transcript` and `world.transcript_lines` are
#                            then nil/empty).
#   * published:             false unpublishes the transcript *and* the collection,
#                            so every public listing (Transcript.get_for_home_page,
#                            Transcript.get_for_homepage, Collection.published)
#                            excludes the world.
#   * lines / speakers:      how many transcript lines and speakers to create; the
#                            lines are round-robined across the speakers.
#   * collection_published:  extra keyword, defaults to `published`; pass it as
#                            true with `published: false` to model an unpublished
#                            transcript inside a live collection (preview specs).
#   * pages:                 page_type => HTML content for further published public
#                            pages; the built records are in `world.pages`.
#   * transcript_attributes: attributes merged into the primary transcript, for
#                            specs that need a known title or `percent_completed`.
#   * extra_transcripts:     attribute hashes for more transcripts in the same
#                            collection; `world.transcripts` lists them all, primary
#                            first.
#   * line_overrides:        sequence => line attributes, e.g.
#                            `{ 0 => { status: 'completed', flagged: true } }`; a
#                            status name comes from ReferenceData, and `flagged`
#                            builds the unresolved error flag the editor counts.
#
# The keywords are collected in `**options` only because Metrics/ParameterLists
# caps explicit parameters at five; `DEFAULTS` is the real signature and unknown
# keys raise.
#
# Every transcript gets spec/fixtures/4k_example_image.jpg attached because the
# listing renders Transcript#image_cropped_thumb_url. Records that the schema
# scopes by project carry `project_uid = ENV['PROJECT_ID']`, otherwise the public
# queries filter them out.
module ContentWorld
  include ContentWorldVariants

  FIXTURE_IMAGE = Rails.root.join('spec/fixtures/4k_example_image.jpg')
  INSTRUCTIONS_CONTENT = '<p>Transcript instructions</p>'

  World = Struct.new(
    :institution, :collection, :transcript, :instructions_page,
    :transcription_conventions, :transcript_lines, :speakers,
    :transcript_line_statuses, :flag_types, :transcripts, :pages, keyword_init: true
  )

  # The editor looks every line's `transcript_line_status_id` up in
  # TranscriptLineStatus.allCached and dereferences `status.name` without a nil
  # guard, so it throws before rendering a single line while that table is empty
  # — and the test database has no seed data for it. Ids are pinned because
  # Postgres sequences are not rolled back between transactional examples, while
  # transcript_lines and TranscriptLine#recalculate hard-code status id 1.
  module ReferenceData
    TRANSCRIPT_LINE_STATUSES = [
      { id: 1, name: 'untranscribed', progress: 0, description: 'No edits submitted yet' },
      { id: 2, name: 'editing', progress: 25, description: 'Edits have been submitted' },
      { id: 3, name: 'reviewing', progress: 50, description: 'Awaiting review' },
      { id: 4, name: 'completed', progress: 100, description: 'Consensus reached' },
      { id: 5, name: 'flagged', progress: 0, description: 'Flagged for attention' },
      { id: 6, name: 'archived', progress: 100, description: 'Archived' }
    ].freeze

    # The editor's flag modal renders one option per FlagType.byCategory('error')
    # (gulp/js/views/transcripts/_flag.js) and refuses to submit without one, so
    # any scenario that flags a line needs these rows.
    FLAG_TYPES = [
      { id: 1, name: 'incorrect', label: 'Incorrect transcription', category: 'error',
        description: 'The text does not match the audio' },
      { id: 2, name: 'missing_words', label: 'Missing words', category: 'error',
        description: 'Words are missing from the text' }
    ].freeze

    module_function

    def ensure_transcript_line_statuses
      TRANSCRIPT_LINE_STATUSES.map do |attributes|
        TranscriptLineStatus.find_by(id: attributes[:id]) || TranscriptLineStatus.create!(attributes)
      end
    end

    def ensure_flag_types
      FLAG_TYPES.map do |attributes|
        FlagType.find_by(id: attributes[:id]) || FlagType.create!(attributes)
      end
    end
  end

  def build_content_world(**options)
    options = world_options(options)
    world = build_world(options)
    world.collection = build_world_collection(world.institution, options[:collection_published])
    world.transcription_conventions = world.institution.transcription_conventions.to_a
    build_transcript_records(world, options)
    world
  end

  def build_world(options)
    World.new(
      institution: build_world_institution,
      instructions_page: build_instructions_page,
      transcript_line_statuses: ReferenceData.ensure_transcript_line_statuses,
      flag_types: ReferenceData.ensure_flag_types,
      pages: build_public_pages(options[:pages])
    )
  end

  private

  # TranscriptsController#show reads
  # `Page.find_by(page_type: 'instructions').public_page`, and Page only creates
  # (and keeps in sync) its PublicPage when it is published.
  def build_instructions_page
    page = Page.find_or_initialize_by(page_type: 'instructions')
    page.content = INSTRUCTIONS_CONTENT
    page.published = true
    page.save!
    page
  end

  def build_world_collection(institution, published)
    create(
      :collection,
      institution: institution,
      project_uid: ENV.fetch('PROJECT_ID'),
      publish: published ? 1 : 0
    )
  end

  def transcript_image_attributes
    {
      image: fixture_file_upload(FIXTURE_IMAGE, 'image/jpeg'),
      crop_x: 0,
      crop_y: 0,
      crop_w: 400,
      crop_h: 200
    }
  end

  def build_speakers(transcript, collection, count)
    Array.new(count) do |index|
      speaker = create(:speaker, name: "Speaker #{index + 1}")
      # TranscriptSpeaker has no `collection` association (only a `collection_id`
      # column), so the factory's `collection` declaration is satisfied by
      # passing the id, as the existing specs do.
      create(
        :transcript_speaker,
        transcript: transcript,
        speaker: speaker,
        collection_id: collection.id,
        project_uid: collection.project_uid
      )
      speaker
    end
  end

  def build_transcript_lines(transcript, count, speakers, overrides)
    Array.new(count) do |index|
      line = build_transcript_line(transcript, index, speakers, overrides[index])
      add_line_flag(line) if overrides.dig(index, :flagged)
      line
    end
  end

  def build_transcript_line(transcript, index, speakers, override)
    original_text = "Transcript line #{index + 1} original text."
    start_time = index * Transcript.seconds_per_line * 1000
    create(
      :transcript_line,
      transcript: transcript,
      sequence: index,
      start_time: start_time,
      end_time: start_time + 4000,
      original_text: original_text,
      speaker_id: speakers.any? ? speakers[index % speakers.size].id : 0,
      **line_attributes(override, original_text)
    )
  end

  # `line_overrides:` is keyed by line sequence (see ContentWorldVariants).
  # `status:` names a row of TRANSCRIPT_LINE_STATUSES; a completed line also
  # carries consensus text, as a real one does. `flagged:` says the line has an
  # unresolved error flag, which is the `flag_count` the editor renders from.
  def line_attributes(override, original_text)
    override = (override || {}).dup
    status_name = override.delete(:status)
    attributes = {}
    if status_name
      attributes[:transcript_line_status_id] = TranscriptLineStatus.find_by!(name: status_name).id
      attributes[:text] = original_text if status_name.to_s == 'completed'
    end
    attributes[:flag_count] = 1 if override.delete(:flagged)
    attributes.merge(override)
  end

  # `flag_count` alone only says a line has flags; a flagged line also needs the
  # flag it counts, so resolving it has something to resolve.
  def add_line_flag(line)
    create(:flag, transcript_line: line, transcript_id: line.transcript_id,
                  flag_type_id: ReferenceData::FLAG_TYPES.first[:id])
  end
end

RSpec.configure do |config|
  config.include ContentWorld
end
