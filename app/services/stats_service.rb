class StatsService
  attr_accessor :user

  def initialize(user, start_date = nil, end_date = nil)
    @user = user
    @start_date = start_date
    @end_date = end_date
  end

  def all_stats
    cache_keys = [
      "stats_service",
      "all_stats",
      @user.id,
      @start_date.to_i,
      @end_date.to_i,
    ]
    Rails.cache.fetch(cache_keys, expires_in: 24.hours) do
      {
        transcript_edits: transcript_edits,
        user_registration_stats: user_registrations,
      }
    end
  end

  def transcript_edits(institution_id = nil)
    {
      all: get_stats_by_day(institution_id).count,
      past_30_days: past_n_days(institution_id, 30).count,
      past_7_days: past_n_days(institution_id, 7).count,
      past_24_hours: past_n_days(institution_id, 1).count,
    }
  end

  # rubocop:disable Metrics/AbcSize
  def completion_stats(institution_id = nil, collection_id = nil)
    scope = stats_scope(institution_id, collection_id)
    total_count = scope.count
    total_lines_count = scope.sum(:lines)
    total_lines_count += 1 if total_lines_count.zero?
    total_lines_completed = scope.sum(:lines_completed)
    total_lines_reviewing = scope.sum(:lines_reviewing)
    total_lines_edited = scope.sum(:lines_edited)
    {
      total: total_count,
      completed: ((total_lines_completed.to_f / total_lines_count) * 100).round(2),
      in_review: ((total_lines_reviewing.to_f / total_lines_count) * 100).round(2),
      in_draft: (((total_lines_edited - total_lines_completed - total_lines_reviewing).to_f / total_lines_count) * 100).round(2),
      not_yet_started: (
        (1.0 - (total_lines_edited.to_f / total_lines_count)) * 100
      ).round(2),
      duration: scope.sum(&:duration),
    }
  end
  # rubocop:enable Metrics/AbcSize

  def user_registrations
    {
      all: user_get_stats_by_day.count,
      past_30_days: user_past_n_days(30).count,
      past_7_days: user_past_n_days(7).count,
      past_24_hours: user_past_n_days(1).count,
    }
  end

  def past_n_days(institution_id, days)
    get_stats_by_day(institution_id).where(created_at: days.days.ago..Time.zone.now)
  end

  def user_past_n_days(days)
    user_get_stats_by_day.where(created_at: days.days.ago..Time.zone.now)
  end

  def disk_usage(institution_id = nil, collection_id = nil)
    return Collection.find(collection_id).disk_usage unless collection_id.nil?
    return Institution.find(institution_id).disk_usage unless institution_id.nil?

    Institution.all_institution_disk_usage
  end

  private

  def stats_scope(institution_id, collection_id)
    scope = Transcript.
      joins("INNER JOIN collections ON
      transcripts.collection_id = collections.id")
    scope = scope.where("collections.institution_id = ?", institution_id) if institution_id
    scope = scope.where("collections.id = ?", collection_id) if collection_id
    scope = scope.where("transcripts.updated_at >= ?", @start_date) if @start_date.present?
    scope = scope.where("transcripts.updated_at <= ?", @end_date) if @end_date.present?
    scope
  end

  def get_stats_by_day(institution_id)
    TranscriptEditPolicy::Scope.new(user, TranscriptEdit).resolve(institution_id)
  end

  def user_get_stats_by_day
    UserPolicy::Scope.new(user, User).resolve
  end
end
