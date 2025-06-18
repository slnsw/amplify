class TranscriptEdit < ApplicationRecord
  has_paper_trail
  belongs_to :transcript
  belongs_to :transcript_line

  validates :session_id, presence: true
  validates :transcript_id, numericality: { only_integer: true }, presence: true
  validates :transcript_line_id, numericality: { only_integer: true }, presence: true
  validates :is_deleted, numericality: { only_integer: true }
  # validates :text, presence: true

  def normalizedText
    # downcase; remove punctuation; remove extra whitespace; remove umm's/uhh's/uhm's, trim
    text.downcase.gsub(/[^0-9a-z ]/i, " ").gsub(/\bu+h+m*\b|\bu+m+\b/, " ").gsub(/\s+/, " ").strip
  end

  def self.getByLine(transcript_line_id)
    TranscriptEdit.
      select('transcript_edits.*,
      COALESCE(user_roles.name, \'guest\') as user_role,
      COALESCE(user_roles.hiearchy, 0) as user_hiearchy,
      COALESCE(user_roles.transcribing_role, \'registered_user\') as transcribing_role').
      joins('LEFT OUTER JOIN users ON users.id = transcript_edits.user_id
              LEFT OUTER JOIN user_roles ON user_roles.id = users.user_role_id').
      where(transcript_line_id: transcript_line_id, is_deleted: 0)
  end

  def self.getByUser(user_id)
    TranscriptEdit.where(user_id: user_id, is_deleted: 0)
  end

  def self.getByLineForDisplay(transcript_line_id)
    TranscriptEdit.where(transcript_line_id: transcript_line_id, is_deleted: 0)
  end

  def self.getByTranscript(transcript_id)
    TranscriptEdit.where(transcript_id: transcript_id, is_deleted: 0)
  end

  def self.getByTranscriptSession(transcript_id, session_id)
    TranscriptEdit.where(transcript_id: transcript_id, session_id: session_id, is_deleted: 0)
  end

  def self.getByTranscriptUser(transcript_id, user_id)
    TranscriptEdit.where(transcript_id: transcript_id, user_id: user_id, is_deleted: 0)
  end

  def self.getStatsByDay
    Rails.cache.fetch("#{ENV['PROJECT_ID']}/transcript_edits/stats", expires_in: 10.minutes) do
      TranscriptEdit.
        select("DATE(created_at) AS date, COUNT(*) AS count").
        group("DATE(created_at)").
        order("DATE(created_at)")
    end
  end

  def self.updateUserSessions(session_id, user_id)
    edits = TranscriptEdit.where(session_id: session_id)
    edits.update_all(user_id: user_id)

    user = User.find(user_id)
    user.incrementLinesEdited(edits.length) if user && edits.length > 0
  end
end
