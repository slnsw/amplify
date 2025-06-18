lock "3.17.3"

set :application, "nsw-state-library-amplify"
# set :scm, :git
set :repo_url, "https://github.com/slnsw/amplify.git"
set :branch, :develop
set :deploy_to, "/home/deploy/nsw-state-library-amplify"
set :pty, false
set :linked_files, %w{config/database.yml config/application.yml config/frontend.yml config/initializers/bugsnag.rb}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle node_modules config/certificates app/files/uploads}
set :keep_releases, 5
set :rvm_type, :user
set :rvm_ruby_version, "ruby-3.0.0"
set :rake, "RAILS_ENV=#{fetch(:rails_env)} bundle exec rake" # force to set RAILS_ENV

set :puma_rackup, -> { File.join(current_path, "config.ru") }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_access.log"
set :puma_error_log, "#{shared_path}/log/puma_error.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env))
set :puma_threads, [0, 8]
set :puma_workers, 0
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_preload_app, false

# Necessary for Sidekiq support.
set :sidekiq_processes, 5
set :sidekiq_user, "deploy"
set :init_system, :systemd
append :rvm1_map_bins, "rake", "gem", "bundle", "ruby", "puma", "pumactl", "sidekiq", "sidekiqctl"
set :bundler_path, "/home/deploy/.rvm/wrappers/ruby-3.0.0@global/bundle"
SSHKit.config.command_map[:sidekiq] = "bundle exec sidekiq"
SSHKit.config.command_map[:sidekiqctl] = "bundle exec sidekiqctl"

# Necessary for Whenever support.
set :whenever_path, -> { release_path }

namespace :deploy do
  after :updated, :update_config do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "project:load['nsw-state-library-amplify']"
          execute :rake, "assets:precompile"
          execute :rake, "cache:clear"
          execute :rake, "sitemap:generate"
        end
      end
    end
  end
end
