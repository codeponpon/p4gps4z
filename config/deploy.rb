require "bundler/capistrano"


set :application, "pagpos"
set :user, "pagposazure"


set :scm, :git
set :repository, "https://github.com/codeponpon/p4gps4z.git"
set :branch, "master"
set :use_sudo, true

set :whenever_command, "RAILS_ENV=production bundle exec whenever"
require "whenever/capistrano"

server "pagposv1.cloudapp.net", :web, :app, :db, primary: true


set :deploy_to, "/home/#{user}/apps/#{application}"
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:port] = 22

set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

set :normalize_asset_timestamps, false

namespace :deploy do
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
    run "cd #{release_path} && #{whenever_command}"
  end

  task :run_workers, roles: :app, except: {no_release: true} do
    run "cd #{release_path} && RAILS_ENV=production COUNT=5 QUEUE=* bundle exec rake resque:workers"
  end

  # task :remove_assets, roles: :app do 
  #   run "bundle exec rake assets:clean"
  # end

  namespace :assets do
    task :update_asset_mtimes, :roles => lambda { assets_role }, :except => { :no_release => true } do
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

  after "deploy:finalize_update", "deploy:symlink_config"
  after "deploy:finalize_update", "deploy:fix_permissions"
  after "deploy", "deploy:run_workers"
  after "deploy:run_workers", "deploy:run_whenever"
  # after "deploy:finalize_update", "deploy:remove_assets"
end