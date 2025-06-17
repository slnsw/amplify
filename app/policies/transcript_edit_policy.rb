# frozen_string_literal: true

class TranscriptEditPolicy < ApplicationPolicy
  attr_reader :user, :scope

  def initialize(user, scope)
    @user = user
    @scope = scope
  end

  class Scope < Scope
    # rubocop:disable Metrics/MethodLength
    def resolve(institution_id = nil)
      if institution_id
        TranscriptEdit
          .select('transcript_edits.*')
          .joins("INNER JOIN transcripts ON
                  transcript_edits.transcript_id = transcripts.id
                  INNER JOIN collections ON
                  transcripts.collection_id = collections.id")
          .where(collections: { institution_id: institution_id })
      else
        TranscriptEdit.all
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
