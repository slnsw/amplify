class Flag < ApplicationRecord
  has_paper_trail
  belongs_to :transcript_line
  belongs_to :flag_type, optional: true

  def self.getByLine(transcript_line_id)
    Flag
      .select('flags.*, flag_types.label as flag_type_label,
      CASE
        WHEN users.id IS null THEN \'anonymous user\'
        WHEN user_roles.name IS NOT null THEN user_roles.name
        ELSE \'registered user\'
      END as user_name,
      COALESCE(user_roles.name, \'guest\') as user_role,
      COALESCE(user_roles.hiearchy, 0) as user_hiearchy,
      COALESCE(user_roles.transcribing_role, \'registered_user\') as transcribing_role')
      .joins('INNER JOIN flag_types ON flags.flag_type_id = flag_types.id
              LEFT OUTER JOIN users ON users.id = flags.user_id
              LEFT OUTER JOIN user_roles ON user_roles.id = users.user_role_id')
      .where("flags.transcript_line_id = :transcript_line_id
              AND flags.is_deleted = :is_deleted
              AND flag_types.category = :category",
              { transcript_line_id: transcript_line_id, is_deleted: 0, category: 'error' })
  end

  def self.getByTranscriptSession(transcript_id, session_id)
    Flag.where(transcript_id: transcript_id, session_id: session_id, is_deleted: 0)
  end

  def self.getByTranscriptUser(transcript_id, user_id)
    Flag.where(transcript_id: transcript_id, user_id: user_id, is_deleted: 0)
  end

  def self.pending_flags(institution_id = nil)
    ar_relation = Flag
      .select('flags.*, flag_types.label as flag_type_label,
      transcripts.uid as transcript_uid, transcripts.title as transcript_title,
      transcript_lines.start_time')
      .joins('INNER JOIN flag_types ON flags.flag_type_id = flag_types.id
      INNER JOIN transcripts ON flags.transcript_id = transcripts.id
      INNER JOIN transcript_lines ON flags.transcript_line_id = transcript_lines.id')
      .where("flags.is_resolved = :is_resolved AND flags.is_deleted = :is_deleted AND flag_types.category = :category",
      {is_resolved: 0, is_deleted: 0, category: 'error'})
   ar_relation = ar_relation.joins('INNER JOIN collections on transcripts.collection_id = collections.id').where("collections.institution_id = ?", institution_id) if institution_id
   ar_relation.order(:transcript_id, "transcript_lines.start_time")
  end

  def self.resolve(transcript_line_id)
    flags = Flag.where(transcript_line_id: transcript_line_id)
    flags.update_all(is_resolved: 1)
  end

  def self.updateUserSessions(session_id, user_id)
    flags = Flag.where(session_id: session_id)
    flags.update_all(user_id: user_id)
  end
end
