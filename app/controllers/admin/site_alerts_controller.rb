# frozen_string_literal: true

module Admin
  class SiteAlertsController < AdminController
    before_action :set_site_alert, only: %i[edit update destroy show]

    def index
      authorize SiteAlert
      @site_alerts = policy_scope(SiteAlert).order(created_at: :desc)
    end

    def new
      authorize SiteAlert
      @site_alert = SiteAlert.new
    end

    def create
      authorize SiteAlert

      @site_alert = SiteAlert.new(site_alert_params)

      if @site_alert.save
        redirect_to admin_site_alerts_path
      else
        render :new
      end
    end

    def edit; end

    def show
      @site_alert = @site_alert.decorate
    end

    def update
      if @site_alert.update(site_alert_params)
        redirect_to admin_site_alerts_path
      else
        render :edit
      end
    end

    def destroy
      @site_alert.destroy
      redirect_to admin_site_alerts_path
    end

    private

    def set_site_alert
      @site_alert = SiteAlert.find(params[:id])
    end

    def site_alert_params
      params.require(:site_alert).permit(
        :level,
        :machine_name,
        :message,
        :published,
        :admin_access,
        :publish_at,
        :unpublish_at
      )
    end
  end
end
