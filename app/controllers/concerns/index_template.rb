# frozen_string_literal: true

module IndexTemplate
  extend ActiveSupport::Concern

  def environment_file(filename)
    tpl_file = "public/#{ENV.fetch('PROJECT_ID', nil)}/#{filename}.html"
    env_tpl_file = "public/#{ENV.fetch('PROJECT_ID', nil)}/#{filename}.#{Rails.env.downcase}.html"
    tpl_file = env_tpl_file if File.exist?(env_tpl_file)
    environment_app_config
    tpl_file
  end

  def environment_app_config
    app_config = ENV.fetch('APP_CONFIG', nil)
    @app_config = app_config.to_json
  end
end
