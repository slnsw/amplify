class Admin::StatsController < AdminController
  before_action :authenticate_staff!

  def index
    authorize :stats, :index?

    @institutions = policy_scope(Institution)
    @stats = StatsService.new(current_user).all_stats
    @flags = Flag.pending_flags(current_user.institution_id)
  end

  def institution
    id = params[:id] ||= 0
    @stats = StatsService.new(current_user, start_date, end_date).transcript_edits(id)
  end

  private

  def start_date
    params[:start_date].to_i > 0 ? params[:start_date] : nil
  end

  def end_date
    params[:end_date].to_i > 0 ? params[:end_date] : nil
  end
end
