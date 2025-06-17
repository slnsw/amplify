# frozen_string_literal: true

require 'csv'

module Admin
  class ReportsController < AdminController
    before_action :authenticate_admin!
    before_action :get_date_params

    def index; end

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
      @users = User.getReport(
        page: @page,
        per_page: @per_page,
        start_date: @start_date,
        end_date: @end_date
      )

      @start_date_str = ''
      @start_date_str = @start_date.strftime('%Y-%m-%d') if @start_date

      @end_date_str = ''
      @end_date_str = @end_date.strftime('%Y-%m-%d') if @end_date

      respond_to do |wants|
        wants.html
        wants.csv do
          render_csv("users-#{Time.zone.now.strftime('%Y%m%d-%H%M%S')}")
        end
      end
    end

    private

    def get_date_params
      # default to all time
      @start_date = 10.years.ago.in_time_zone('Australia/Sydney').midnight
      @end_date = DateTime.now.in_time_zone('Australia/Sydney').end_of_day
      @page = 1
      @per_page = 20

      # look for parameters
      if params['start_date'].present?
        @start_date = params['start_date'].to_datetime.in_time_zone('Australia/Sydney').midnight
      end
      if params['end_date'].present?
        @end_date = params['end_date'].to_datetime.in_time_zone('Australia/Sydney').end_of_day
      end
      @page = params['page'].to_i if params['page'].present?
      @per_page = params['per_page'].to_i if params['per_page'].present?

      @per_page_options = [
        [20, 20],
        [50, 50],
        [100, 100],
        ['All (warning: will take ages)', 99_999_999]
      ]
    end

    def render_csv(filename = nil)
      filename ||= params[:action]
      filename += '.csv'

      if request.env['HTTP_USER_AGENT'] =~ /msie/i
        headers['Pragma'] = 'public'
        headers['Content-type'] = 'text/plain'
        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
        headers['Expires'] = '0'
      else
        headers['Content-Type'] ||= 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      end

      render layout: false
    end
  end
end
