source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.5.3"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.2.0"
gem "activesupport", "~> 5.2.0"
gem "marcel", "~> 0.3"
gem "msgpack", [">= 1.0.0", "< 1.4.0"]

# Use PostgreSQL as the database for Active Record
gem "pg", "~> 1.1.4"
gem "pg_search", "~> 2.1.4"
gem "will_paginate", "~> 3.1.6"

gem "puma", "~> 3.12.0"

# Caching
gem "dalli", "~> 2.7.9"

# Disabling assets; replaced with Gulp
gem "autoprefixer-rails", "~> 8.6", ">= 8.6.5"
gem "bootstrap", "~> 4.1.1"
gem "coffee-rails", "~> 4.2"
gem "font-awesome-rails", "~> 4.7.0"
gem "jquery-rails", "~> 4.3.3"
gem "sass-rails", "~> 5.0"
gem "select2-rails", "~> 4.0.13"
gem "summernote-rails", "~> 0.8.10"
gem "uglifier", ">= 1.3.0"

# Back-end App is treated mostly as a JSON API
gem "jbuilder", "~> 2.5"

# gem 'rails-api' # pare down rails to act like an API; disabling unnecessary middleware
gem "rack-cors", "~> 1.0.2", require: "rack/cors"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Rails app configuration / ENV management
gem "figaro", "~> 1.1.1"

# User management / auth.
# We have to force the version of OAuth because omniauth-google-oauth2 v0.6
# requires jwt v2.0 or better.
# Facebook's gem is a bit behind.
gem "devise", "~> 4.6.1"
# gem 'devise-security'
gem "oauth2", github: "oauth-xx/oauth2", ref: "v1.4.1"
gem "omniauth-facebook", "~> 5.0.0"
gem "omniauth-google-oauth2", ">= 0.6.0"

# Beef up security.
gem "invisible_captcha", "~> 0.12.0"
gem "rack-attack", "~> 6.0.0"

# Niceties.
gem "exception_handler", "~> 0.8.0"

# Parsers for project asset precompilation
gem "ejs", "~> 1.1.1"
gem "execjs", "~> 2.7.0"
gem "redcarpet", "~> 3.4.0"

# For audio transcripts
gem "webvtt-ruby", "~> 0.3.2"

# For uploading of transcipts and image files
# load fog-aws first to reduce the number of imported classes
gem "carrierwave", "~> 1.1"
gem "fog", "~> 2.1.0"
gem "mini_magick", "~> 4.8"

# Error logging
gem "newrelic_rpm", "~> 6.1.0"
gem "rails_12factor", "~> 0.0.3"

# Installation script.
gem "highline", "~> 2.0.1"

# Use unicorn on linux only
platforms :ruby do # linux
  gem "unicorn", "~> 5.5.0"
end

group :development, :test do
  gem "byebug", "~> 11.0.0", platforms: [:mri, :mingw, :x64_mingw]
  gem "factory_bot_rails", "~> 5.0.2"
  gem "faker", "~> 1.9.3"
  gem "pry", "~> 0.12.2"
  gem "rspec-rails", "~> 3.4"
end

group :development do
  gem "foreman"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"

  gem "capistrano", "~> 3.11.0"
  gem "capistrano3-puma", "~> 3.1.1"
  gem "capistrano-bundler", "~> 1.6.0", require: false
  gem "capistrano-npm", "~>1.0.3"
  gem "capistrano-rails", "~> 1.4.0", require: false
  gem "capistrano-rvm", "~> 0.1.2"
  gem "capistrano-sidekiq", "~> 1.0.2"
  gem "rubocop", "~> 0.65.0"

  gem "bcrypt_pbkdf", "~> 1.1"
  gem "ed25519", "~> 1.2"

  gem "dotenv-rails", "~> 2.7.1"
  gem "letter_opener", "~> 1.7.0"
  gem "reinteractive-style", "~> 0.2.8"
end

group :test do
  gem "capybara", ">= 2.15", "< 4.0"
  gem "launchy", "~> 2.4.0"
  gem "pundit-matchers", "~> 1.6.0"
  gem "rails-controller-testing", "~> 1.0.4"
  gem "selenium-webdriver", "~> 3.141.0"
  gem "shoulda-matchers", "~> 3.1", require: false
  gem "simplecov", "~> 0.16.1"
  gem "webdrivers", "~> 4.1.2"
end

group :staging, :production do
  gem "executable-hooks", "~> 1.6.0"
end

gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# tracking errors
gem "bugsnag", "~> 6.11.1"
gem "draper", "~> 3.1.0"
gem "sanitize", "~> 5.0.0"

gem "acts_as_singleton", "~> 0.0.8"
gem "acts-as-taggable-on", "~> 6.0"
gem "chartkick", "~> 3.0.2"
gem "formdata", "~> 0.1.2"
gem "friendly_id", "~> 5.2.0"
gem "httparty", "~> 0.16.4"
gem "pundit", "~> 2.0.1"
gem "rest-client", "~> 2.0.2"
gem "seed_migration", "~> 1.2.3"
gem "sidekiq", "< 6"
gem "sidekiq-cron", "~> 1.2.0"

# Track object changes
gem "paper_trail", "~> 10.3.1"
