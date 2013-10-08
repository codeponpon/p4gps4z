# set :application, 'pagpos'
# set :repo_url, 'git@github.com:codeponpon/p4gps4z.git'

# # ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# # set :deploy_to, '/var/www/my_app'
# # set :scm, :git

# # set :format, :pretty
# # set :log_level, :debug
# # set :pty, true

# # set :linked_files, %w{config/database.yml}
# # set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# # set :default_env, { path: "/opt/ruby/bin:$PATH" }
# # set :keep_releases, 5

# namespace :deploy do

#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       # Your restart mechanism here, for example:
#       # execute :touch, release_path.join('tmp/restart.txt')
#     end
#   end

#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#     end
#   end

#   after :finishing, 'deploy:cleanup'

# end

require "bundler/capistrano"


set :application, "pagpos"
set :user, "pagposazure"


set :scm, :git
set :repository, "git@github.com:codeponpon/p4gps4z.git"
set :branch, "master"
set :use_sudo, true


server "pagposv1.cloudapp.net", :web, :app, :db, primary: true


set :deploy_to, "/home/#{user}/repositories/#{application}"
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:port] = SSHPort


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
  after "deploy:finalize_update", "deploy:fix_permissions"
  after "deploy:finalize_update", "deploy:symlink_config"
end
