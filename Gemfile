# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.4'

# Standard library gems removed for Ruby 3.4+, thus, needs to be installed separately
gem 'abbrev'
gem 'base64'
gem 'bigdecimal'
gem 'csv'
gem 'observer'
gem 'open-uri'
gem 'ostruct'
gem 'time'
gem 'uri'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0.2'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.0'
gem 'puma-daemon', '~> 0.5', require: false

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder', '~> 2.13.0'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'marcel', '~> 1.0.2'

# Use PostgreSQL as the database for Active Record
gem 'pg', '1.5.9'
gem 'pg_search', '~> 2.1.4'
gem 'will_paginate', '~> 3.3.0'

# Caching
gem 'dalli', '~> 3.0'

# Disabling assets; replaced with Gulp
gem 'autoprefixer-rails', '~> 8.6', '>= 8.6.5'
# TODO: Upgrade to Bootstrap 5.x.x to fix vulnerabilities
gem 'bootstrap', '~> 4.1.1'
gem 'coffee-rails', '~> 4.2'
gem 'font-awesome-rails', '~> 4.7.0'
gem 'jquery-rails', '~> 4.6.0'
gem 'sass-rails', '~> 5.0'
gem 'select2-rails', '~> 4.0.13'
gem 'summernote-rails', '0.8.10'
gem 'uglifier', '>= 1.3.0'

# gem 'rails-api' # pare down rails to act like an API; disabling unnecessary middleware
gem 'rack-cors', '~> 1.0.2', require: 'rack/cors'

# Rails app configuration / ENV management
gem 'figaro'

# User management / auth.
# We have to force the version of OAuth because omniauth-google-oauth2 v0.6
# requires jwt v2.0 or better.
# Facebook's gem is a bit behind.
gem 'devise', '~> 4.9.4'
gem 'jwt'
# gem 'devise-security'
gem 'oauth2', github: 'oauth-xx/oauth2', ref: 'v2.0.1'
gem 'omniauth-facebook', '~> 9.0.0'
gem 'omniauth-google-oauth2', '< 1.1.1'
gem 'omniauth-rails_csrf_protection'

# Beef up security.
gem 'invisible_captcha', '~> 0.12.0'
gem 'rack-attack', '~> 6.0.0'

# Niceties.
gem 'exception_handler', '~> 0.8.0'

# Parsers for project asset precompilation
gem 'ejs', '~> 1.1.1'
gem 'execjs', '~> 2.7.0'
gem 'redcarpet', '~> 3.6.1'

# For audio transcripts
gem 'webvtt-ruby', '~> 0.3.2'

# For uploading of transcipts and image files
# load fog-aws first to reduce the number of imported classes
gem 'carrierwave', '~> 3.0'
# require installation of the following
# sudo apt-get install build-essential libcurl4-openssl-dev
# this is to allow fog get installed with ovirt-engine-sdk
# gem "fog", "~> 2.3.0"
# Using specific providers to avoid ovirt-engine-sdk compatibility issues with Ruby 3.4
gem 'fog-aws'
gem 'fog-core'
gem 'fog-local'
gem 'mini_magick', '~> 4.8'

# Error logging
gem 'newrelic_rpm'
gem 'rails_12factor', '~> 0.0.3'

# Installation script.
gem 'highline', '~> 2.0.1'

# Use unicorn on linux only
platforms :ruby do # linux
  gem 'unicorn'
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  # DISABLED: Rails 8.0 debug gem conflicts with Pry - use Pry instead
  # gem "debug", platforms: [:mri, :mingw, :x64_mingw]

  gem 'byebug', '~> 11.0.0', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 5.0.2'
  gem 'faker'
  gem 'pry', '~> 0.15.0'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 6.0.0'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem 'foreman'
  gem 'listen', '~> 3.5'
  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'capistrano', '~> 3.19.2', require: false
  gem 'capistrano3-puma', github: 'seuros/capistrano-puma'
  gem 'capistrano-bundler', '~> 2.0'
  gem 'capistrano-npm'
  gem 'capistrano-rails', '~> 1.6', require: false
  gem 'capistrano-rvm'
  gem 'capistrano-sidekiq'
  gem 'rubocop', '~> 1.69'
  gem 'rubocop-rails', '~> 2.27'
  gem 'rubocop-rspec', '~> 3.3'
  gem 'sshkit', '~> 1.23'
  gem 'stringio'

  gem 'bcrypt_pbkdf', '~> 1.1'
  gem 'ed25519', '~> 1.2'

  gem 'brakeman'
  gem 'dotenv-rails', '~> 2.7.1'
  gem 'letter_opener', '~> 1.7.0'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'

  gem 'launchy', '~> 2.4.0'
  gem 'pundit-matchers', '~> 1.6.0'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'shoulda-matchers', '~> 3.1', require: false
  gem 'simplecov', '~> 0.16.1'
end

group :staging, :production do
  gem 'executable-hooks', '~> 1.6.0'
end

# tracking errors
gem 'bugsnag'
gem 'draper', '~> 4.0.2'
gem 'nokogiri', '~> 1.15'
gem 'sanitize', '~> 6.0.0'

gem 'acts_as_singleton', '~> 0.0.8'
gem 'acts-as-taggable-on', '~> 12.0'
gem 'chartkick', '~> 5.0.1'
gem 'formdata', '~> 0.1.2'
gem 'friendly_id', '~> 5.2.0'
gem 'pundit', '~> 2.0.1'
gem 'rest-client', '~> 2.0.2'
gem 'seed_migration', '~> 1.2.3'
gem 'sidekiq', '~> 7.0'
gem 'sidekiq-cron', '~> 2.3'

# Track object changes
gem 'paper_trail', '~> 16.0'

# Sitemap generator'
gem 'sitemap_generator', '~> 6.3.0'
