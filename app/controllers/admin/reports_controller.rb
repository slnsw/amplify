require 'csv'

class Admin::ReportsController < AdminController
  before_action :authenticate_admin!

  def index
  end

  # GET /reports/edits.json
  # def edits
  #   @edits = TranscriptEdit.getReport(@start_date, @end_date)
  # end

  # GET /reports/transcripts.json
  # def transcripts
  #   @transcripts = Transcript.getReport()
  # end

  # GET /reports/users.json
  def users
    @institutions = policy_scope(Institution).order(:name)
    @collections = policy_scope(Collection).order(:title)

    @user_report = Reports::UserContributions.new(params) 
    @users = @user_report.results
    
    respond_to do |format|
      format.html
      format.csv do
        send_data @user_report.to_csv, filename: "users-#{Time.now.strftime("%Y%m%d-%H%M%S")}.csv"
      end
    end
  end
end
