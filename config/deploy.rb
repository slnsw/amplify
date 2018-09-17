lock '3.11.0'

set :application, 'nsw-state-library-amplify'
# set :scm, :git
set :repo_url, 'git@github.com:slnswgithub/nsw-state-library-amplify.git'
set :branch, :develop
set :deploy_to, '/home/deploy/nsw-state-library-amplify'
set :pty, false
set :linked_files, %w{config/database.yml config/application.yml config/frontend.yml config/initializers/bugsnag.rb}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle config/certificates app/files/uploads }
set :keep_releases, 5
set :rvm_type, :user
set :rvm_ruby_version, 'ruby-2.5.0'

set :puma_rackup, -> { File.join(current_path, 'config.ru') }
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
set :sidekiq_processes, 5

set :sidekiq_user, 'deploy'
set :init_system, :systemd
SSHKit.config.command_map[:sidekiq] = "bundle exec sidekiq"
SSHKit.config.command_map[:sidekiqctl] = "bundle exec sidekiqctl"

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
      execute :rake, 'project:load[\'nsw-state-library-amplify\']'
    end
  end
end
