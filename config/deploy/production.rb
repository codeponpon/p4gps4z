server "pagpos.cloudapp.net", :web, :app, :db, primary: true
server "pagpos.cloudapp.net", :web, :app, :worker

role :app, "pagpos.cloudapp.net" # add more servier "pagposx1.cloudapp.net", "pagposx2.cloudapp.net", "pagposx3.cloudapp.net"
role :db, "pagposdb.cloudapp.net", :primary => true
role :web, "pagpos.cloudapp.net"

set :repository, "git@github.com:codeponpon/p4gps4z.git"
set :branch, "master"

set :branch do
  default_tag = `git tag`.split("\n").last

  tag = Capistrano::CLI.ui.ask "Tag to deploy (make sure to push the tag first): [#{default_tag}] "
  tag = default_tag if tag.empty?
  tag
end