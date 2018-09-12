source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'

# Use PostgreSQL as the database for Active Record
gem 'pg'
gem 'pg_search'
gem 'will_paginate'

gem 'puma'

# Caching
gem 'dalli'

# Disabling assets; replaced with Gulp
gem 'sass-rails', '~> 5.0'
gem 'autoprefixer-rails', '~> 8.6', '>= 8.6.5'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'bootstrap', '~> 4.1.1'
gem "font-awesome-rails"
gem 'summernote-rails'

# gem 'turbolinks', '~> 5'

# Back-end App is treated mostly as a JSON API
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease
# gem 'rails-api' # pare down rails to act like an API; disabling unnecessary middleware
gem 'rack-cors', :require => 'rack/cors'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Rails app configuration / ENV management
gem 'figaro'

# User management / auth
gem 'devise'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'

# Parsers for project asset precompilation
gem 'redcarpet'
gem 'ejs'
gem 'execjs'

# For audio transcripts
gem 'popuparchive'
gem 'webvtt-ruby'

# For uploading of transcipts and image files
# load fog-aws first to reduce the number of imported classes
gem 'fog'
gem 'carrierwave', '~> 1.1'
gem 'mini_magick', '~> 4.8'

# Error logging
gem 'newrelic_rpm'
gem 'rails_12factor'

# Use unicorn on linux only
platforms :ruby do # linux
  gem 'unicorn'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry'
  gem 'rspec-rails', '~> 3.4'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'capistrano'
  gem 'capistrano3-puma'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rvm'
  gem 'rubocop'

  gem 'dotenv-rails'
  gem "reinteractive-style"
  gem "letter_opener"
end

group :test do
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
  gem 'shoulda-matchers', '~> 3.1', require: false
  gem 'simplecov'
  gem 'rails-controller-testing'
  gem 'pundit-matchers', '~> 1.6.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# tracking errors
gem 'bugsnag'
gem 'sanitize'
gem "draper"

gem "pundit"
gem 'friendly_id', '~> 5.2.0'
gem 'acts-as-taggable-on', '~> 6.0'
gem 'seed_migration'
gem 'acts_as_singleton'

gem 'httparty'
gem 'rest-client'
gem 'formdata'
