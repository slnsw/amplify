# frozen_string_literal: true

class FlagDecorator < ApplicationDecorator
  delegate_all

  def institution
    # flag has trasncript id
    # transcript belongs to a collection
    # collection belongs to an institution

    institutions = Institution.joins(
      "INNER JOIN collections on collections.institution_id = institutions.id
      INNER JOIN transcripts on transcripts.collection_id = collections.id
      INNER JOIN flags on flags.transcript_id = transcripts.id"
    )
    institutions.where(flags: { id: object.id }).first
  end
end
