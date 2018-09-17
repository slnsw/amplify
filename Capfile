# Load DSL and set up stages.
require "capistrano/setup"

# Include default deployment tasks.
require "capistrano/deploy"

# To ensure your project is compatible with future versions of Capistrano
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require 'capistrano/bundler'
require 'capistrano/rvm'
require 'capistrano/rails/migrations'
require 'capistrano/sidekiq'

require 'capistrano/puma'
install_plugin Capistrano::Puma

require 'capistrano/seed_migration_tasks'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined.
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
