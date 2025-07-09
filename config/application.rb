require_relative "boot"

# Standard library gems that need to be explicitly required in Ruby 3.4+
require "base64"
require "csv"
require "ostruct"
require "json"

require "rails/all"

# Rails 7.2 compatibility: Add backward compatibility for preview_path= (deprecated in 7.1, removed in 7.2)
# This must run before ActionMailer railtie initializes
module ActionMailerCompat
  def preview_path=(path)
    Rails.logger&.debug "ActionMailer: preview_path= is deprecated. Using preview_paths= instead."
    self.preview_paths = path ? [path] : []
  end
end

ActionMailer::Base.extend(ActionMailerCompat)

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TranscriptEditor
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Load extra libraries.
    config.autoload_paths << Rails.root.join('app', 'lib')
    config.autoload_paths << Rails.root.join('lib', 'voicebase')

    # Disable assets
    config.assets.enabled = false

    # using sidekiq as the default queue
    config.active_job.queue_adapter = :sidekiq

    # API
    config.api_only = false

    config.to_prepare do
      layout = "application_v2"
      Devise::SessionsController.layout layout
      Devise::RegistrationsController.layout layout
      Devise::ConfirmationsController.layout layout
      Devise::UnlocksController.layout layout
      Devise::PasswordsController.layout layout
    end

    config.exception_handler = {
      dev: true,
      db: nil,
      email: nil,
      exceptions: {
        all: {
          layout: 'application_v2',
          notification: true,
        },
        :"4xx" => {
          layout: 'application_v2',
          notification: false,
        }
      }
    }

    config.middleware.use Rack::Attack

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Fix Rails 8.1 deprecation warning about timezone preservation
    config.active_support.to_time_preserves_timezone = :zone
  end
end
