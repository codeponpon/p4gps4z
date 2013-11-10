server "pagposx.cloudapp.net", :web, :app, :db, primary: true
server "pagposx.cloudapp.net", :web, :app, :worker

role :app, "pagposx.cloudapp.net", "pagposx1.cloudapp.net", "pagposx2.cloudapp.net"
role :db, "pagposdbx.cloudapp.net", :primary => true
role :web, "pagposx.cloudapp.net"

set :application, "pagpos"
set :user, "codeponpon"
set :scm, :git
set :repository, "git@github.com:codeponpon/p4gps4z.git"
set :branch, "staging"
set :use_sudo, true

set :branch do
  default_tag = `git tag`.split("\n").last

  tag = Capistrano::CLI.ui.ask "Tag to deploy (make sure to push the tag first): [#{default_tag}] "
  tag = default_tag if tag.empty?
  tag
end