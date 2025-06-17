# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  # Allow us to use JBuilder
  include ActionController::ImplicitRender

  before_action :set_paper_trail_whodunnit
  before_action :touch_session
  before_action :load_user_edits
  before_action :load_footer
  before_action :set_ie_headers
  before_action :load_app_config
  before_action :set_pagination_params

  helper_method :project_key
  helper_method :frontend_config
  helper_method :facebook_app_id

  # Ensure a session id is available for all!
  def touch_session
    session[:touched] = 1
  end

  def load_user_edits
    current_user.total_edits ||= TranscriptEdit.getByUser(current_user.id).count if current_user
  end

  def authenticate_user
    # We allow non logged in users to edit the transcripts
    # raise ActionController::InvalidAuthenticityToken unless current_user
  end

  def load_app_config
    @app_config ||= AppConfig.instance
  end

  def load_footer
    site = Site.new
    @global_content = {
      footer_content: site.footer_content,
      footer_links: site.footer_links
    }
  end

  def set_ie_headers
    response.headers['X-UA-Compatible'] = 'IE=edge'
  end

  def project_key
    ENV['PROJECT_ID']
  end

  def frontend_config
    frontend_config_obj = Rails.application.config_for(:frontend)
    return {} if frontend_config_obj.blank?

    frontend_config_obj
  end

  def facebook_app_id
    ENV['FACEBOOK_APP_ID']
  end

  private

  # Overwriting the sign_out redirect path method
  def after_sign_up_path_for(_resource_or_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource)
    resource.update(remember_me: true)

    if params[:return_to].present?
      uid         = params[:return_to]
      transcript  = Transcript.find_by uid: uid
      collection  = transcript.collection.uid
      institution = transcript.collection.institution.slug

      institution_transcript_path(institution: institution, collection: collection, id: transcript.uid)
    else
      super
    end
  end

  def set_pagination_params
    params[:page] ||= 1
    params[:per_page] ||= 50
  end
end
