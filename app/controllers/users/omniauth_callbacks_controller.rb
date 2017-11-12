# frozen_string_literal: true

module Users
  # rubocop:disable LineLength
  # Overrides OmniauthCallbacksController in devise_token_auth.
  class OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
    # rubocop:enable LineLength
    before_filter :set_user_session, except: [:redirect_callbacks]
    after_filter :handle_user_sessions, except: [:redirect_callbacks]

    # Set a session cookie to work out if previously logged in.
    def set_user_session
      session[:previously_not_logged_in] = false
      session[:previously_not_logged_in] = true unless user_signed_in?
    end

    # Handle user sessions.
    def handle_user_sessions
      set_user_session unless session.key?(:previously_not_logged_in)

      # User just signed in
      restore_previous_session if
        session[:previously_not_logged_in] && user_signed_in?
    end

    # Override for redirect_callbacks in devise_token_auth.
    def redirect_callbacks
      setup_env_params

      session['dta.omniauth.auth'] = request.env['omniauth.auth']
                                            .except('extra')
      session['dta.omniauth.params'] = omniauth_params
      tweak_session_attrs
      has_params = session['dta.omniauth.params']

      redirect_to action: has_params ? 'omniauth_success' : 'omniauth_failure'
    end

    private

    # Tweak environment parameters for the redirect callback.
    def setup_env_params
      unless request.env.key?('omniauth.params')
        request.env['omniauth.params'] = {}
      end
      request.env['omniauth.params']['namespace_name'] = nil
      request.env['omniauth.params']['resource_class'] = 'User'
    end

    # Ensure that the info hash is properly populated.
    def tweak_session_attrs
      tweak_session_attrs_saml
    end

    # Ensure that the info hash is properly populated for SAML.
    # Needs email address at least.
    # Has special handling for Microsoft-specific identity schemas.
    # @TODO: Make configuration more generic.
    def tweak_session_attrs_saml
      return unless valid_saml_session?
      saml_profile_attr_map.each do |d, s|
        tweak_session_attr_saml(d, s)
      end
    end

    def tweak_session_attr_saml(d, s)
      return if info_hash_has?(session['dta.omniauth.auth']['info'], d.to_s)
      info_hash = session['dta.omniauth.auth']['info']
      info_hash = copy_key_if_exists(info_hash, saml_claims_url(s), d)
      info_hash = copy_key_if_exists(info_hash, saml_ms_claims_url(s), d)
      session['dta.omniauth.auth']['info'] = info_hash
    end

    def copy_key_if_exists(info_hash, key, d)
      info_hash[d.to_s] = omniauth_extra[key].first if omniauth_extra.key?(key)
      info_hash
    end

    def omniauth_extra
      request.env['omniauth.auth'].extra.raw_info.attributes
    end

    def saml_profile_attr_map
      {
        name: :displayname,
        email: :emailaddress,
        first_name: :givenname,
        last_name: :surname
      }
    end

    def saml_claims_url(param)
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/' + param.to_s
    end

    def saml_ms_claims_url(param)
      'http://schemas.microsoft.com/identity/claims/' + param.to_s
    end

    def valid_saml_session?
      session['dta.omniauth.auth']['provider'] == 'saml' &&
        ENV['SAML_NAME_ID_FORMAT'] == saml_name_id_format_email
    end

    def info_hash_has?(info_hash, index)
      info_hash[index]
    end

    def saml_name_id_format_email
      'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
    end

    # Restore a previous session if we can.
    def restore_previous_session
      # Assume previous session belongs to user
      restore_previous_non_admin_session
      current_user.setRole('admin') if user_project_admin?
    end

    def restore_previous_non_admin_session
      TranscriptEdit.updateUserSessions(session.id, current_user.id)
      Flag.updateUserSessions(session.id, current_user.id)
    end

    # Check if user is an admin
    def user_project_admin?
      project = Project.getActive
      admin_emails = project[:data]['adminEmails']
      admin_emails.include?(current_user.email) &&
        (
          !current_user.user_role ||
          current_user.user_role.name != 'admin'
        )
    end
  end
end
