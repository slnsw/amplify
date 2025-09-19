class TranscriptSpeakerEdit < ApplicationRecord
  has_paper_trail
  belongs_to :transcript_line
  belongs_to :transcript

  validates :session_id, presence: true
  validates :transcript_id, numericality: { only_integer: true }, presence: true
  validates :transcript_line_id, numericality: { only_integer: true }, presence: true
  validates :speaker_id, numericality: { only_integer: true }, presence: true

  def self.getByLine(transcript_line_id)
    TranscriptSpeakerEdit
      .select('transcript_speaker_edits.*,
      COALESCE(user_roles.name, \'guest\') as user_role,
      COALESCE(user_roles.hiearchy, 0) as user_hiearchy,
      COALESCE(user_roles.transcribing_role, \'registered_user\') as transcribing_role')
      .joins('LEFT OUTER JOIN users ON users.id = transcript_speaker_edits.user_id
              LEFT OUTER JOIN user_roles ON user_roles.id = users.user_role_id')
      .where(transcript_line_id: transcript_line_id)
  end
end
