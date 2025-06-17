# frozen_string_literal: true

module IndexTemplate
  extend ActiveSupport::Concern

  # Render the project set in environment.
  # If there's a different index file available
  # for the current Rails.env, use that instead.
  def environment_index_file
    tpl_file = "public/#{ENV['PROJECT_ID']}/index.html"
    env_tpl_file = "public/#{ENV['PROJECT_ID']}/index.#{Rails.env.downcase}.html"
    tpl_file = env_tpl_file if File.exist?(env_tpl_file)
    environment_app_config
    tpl_file
  end

  def environment_admin_file
    tpl_file = "public/#{ENV['PROJECT_ID']}/admin.html"
    env_tpl_file = "public/#{ENV['PROJECT_ID']}/admin.#{Rails.env.downcase}.html"
    tpl_file = env_tpl_file if File.exist?(env_tpl_file)
    tpl_file
  end

  def environment_app_config
    app_config = ENV['APP_CONFIG']
    @app_config = app_config.to_json
  end
end
