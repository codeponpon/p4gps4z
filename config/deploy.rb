require "bundler/capistrano"

set :stages, [:production]
set :default_stage, "production"
require 'capistrano/ext/multistage'

# Must be set for the password prompt
# from git to work
default_run_options[:pty] = true

set :application, "pagpos"
set :scm, :git
set :use_sudo, false
set :user, "codeponpon"
# set :repository, "git@github.com:codeponpon/p4gps4z.git"
# set :branch, "master"

# This essentially keeps a clone of your app on the server and then just does a git pull to fetch new changes and copies the directory across when you deploy.
# set :repository_cache, "git_cache"

# In most cases you want to use this option, otherwise each deploy will do a full repository clone every time.
set :deploy_via, :remote_cache
# set :deploy_via, :copy

# If you're using your own private keys for git, you want to tell Capistrano to use agent forwarding with this command. Agent forwarding can make key management much simpler as it uses your local keys instead of keys installed on the server.
set :ssh_options, { :forward_agent => true }

set :whenever_command, "RAILS_ENV=#{rails_env} bundle exec whenever"
require "whenever/capistrano"

# server "pagpos.cloudapp.net", :web, :app, :db, primary: true
# server "pagpos.cloudapp.net", :web, :app, :worker

# server "pagposv1.cloudapp.net", :web, :app, :db, primary: true
# server "pagposv1.cloudapp.net", :web, :app, :worker

set :deploy_to, "/home/#{user}/apps/#{application}"
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:port] = 22

set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

set :normalize_asset_timestamps, false

after "deploy:restart", "deploy:restart_workers"

def run_remote_rake(rake_cmd)
  rake_args = ENV['RAKE_ARGS'].to_s.split(',')

  cmd = "cd #{fetch(:latest_release)} && bundle exec #{fetch(:rake, "rake")} RAILS_ENV=#{fetch(:rails_env, rails_env)} #{rake_cmd}"
  cmd += "['#{rake_args.join("','")}']" unless rake_args.empty?
  run cmd
  set :rakefile, nil if exists?(:rakefile)
end

namespace :deploy do
  desc "Restart Resque Workers"
  task :restart_workers, :roles => :worker do
    run_remote_rake "resque:restart_workers"
  end

  desc "Fix permissions"
  task :fix_permissions, :roles => [ :app, :db, :web ] do
    run "chmod +x #{release_path}/config/unicorn_init.sh"
  end


  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "service unicorn_#{application} #{command}"
    end
  end


  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    sudo "mkdir -p #{shared_path}/config"
  end
  after "deploy:setup", "deploy:setup_config"


  task :symlink_config, roles: :app do
    # Add database config here
  end

  task :run_whenever, roles: :app, except: {no_release: true} do
    run "cd #{current_path} && #{whenever_command}"
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec whenever --update-crontab pagpos"
  end

  task :run_workers, roles: :app, except: {no_release: true} do
    run "cd #{current_path} && PIDFILE=./resque.pid BACKGROUND=yes COUNT=5 QUEUE=* bundle exec rake environment resque:workers"
  end

  # task :remove_assets, roles: :app do
  #   run "bundle exec rake assets:clean"
  # end

  namespace :assets do
    task :update_asset_mtimes, :roles => lambda { assets_role }, :except => { :no_release => true } do
    end
  end

  # ...lots of other code
  namespace :bundle do

    desc "run bundle install and ensure all gem requirements are met"
    task :install do
      run "cd #{current_path} && bundle install  --without=test --no-update-sources"
    end

  end

  # namespace :assets do
  #   desc "Precompile assets on local machine and upload them to the server."
  #   task :precompile, roles: :web, except: {no_release: true} do
  #     run_locally "bundle exec rake assets:precompile"
  #     find_servers_for_task(current_task).each do |server|
  #       run_locally "rsync -vr --exclude='.DS_Store' public/assets #{user}@#{server.host}:#{shared_path}/"
  #     end
  #   end
  # end

  before "deploy:restart", "bundle:install"
  after "deploy:finalize_update", "deploy:symlink_config"
  after "deploy:finalize_update", "deploy:fix_permissions"
  after "deploy", "deploy:run_whenever"
  # after "deploy:run_whenever", "deploy:cleanup"
  # after "deploy:run_whenever", "deploy:run_workers"
  # after "deploy:finalize_update", "deploy:remove_assets"
end