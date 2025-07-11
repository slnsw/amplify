# Be sure to restart your server when you modify this file.
#
# This file eases your Rails 7.2 framework defaults upgrade.
#
# Uncomment each configuration one by one to switch to the new default.
# Once your application is ready to run with all new defaults, you can remove
# this file and set the `config.load_defaults` to `7.2`.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.
# https://guides.rubyonrails.org/upgrading_ruby_on_rails.html

# ActionMailer preview_path was removed in Rails 7.2, replaced with preview_paths
# If you had custom preview_path settings, migrate them to preview_paths:
# config.action_mailer.preview_paths = ["test/mailers/previews", "lib/mailer_previews"]

# Enable YJIT by default if running Ruby 3.3+
# Rails.application.config.yjit = true

# Set a new default for the Puma thread count
# Rails.application.config.force_ssl = false

# Prevent jobs from being scheduled within transactions
# Rails.application.config.active_job.enqueue_after_transaction_commit = :default

# Fix Rails 8.1 deprecation warning about timezone preservation
Rails.application.config.active_support.to_time_preserves_timezone = :zone

# No longer add autoloaded paths to $LOAD_PATH. This means that you won't be able
# to manually require files that are managed by the autoloader, which you shouldn't do anyway.
# This will reduce the size of the $LOAD_PATH and avoid some Ruby warnings.
#
# Rails.application.config.add_autoload_paths_to_load_path = false

# Remove the default X-Download-Options headers since it is used only by Internet Explorer.
# If you need to support Internet Explorer, add back `"X-Download-Options" => "noopen"`.
#
# Rails.application.config.force_ssl = true

# Change the default headers to disable browsers' flawed legacy XSS protection.
#
# Rails.application.config.force_ssl = true

# Other Rails 7.2 defaults would go here as needed...