server "pagpos.cloudapp.net", :web, :app, primary: true
server "pagpos.cloudapp.net", :web, :app, :worker
# server "pagposdev.cloudapp.net", :db

role :app, "pagpos.cloudapp.net" # add more servier "pagposx1.cloudapp.net", "pagposx2.cloudapp.net", "pagposx3.cloudapp.net"
# role :db, "pagposdb.cloudapp.net", :primary => true
role :web, "pagpos.cloudapp.net"

set :repository, "git@github.com:codeponpon/p4gps4z.git"
set :branch, "master"