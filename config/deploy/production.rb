server "p4gp0s.cloudapp.net", :web, :app, primary: true
server "p4gp0s.cloudapp.net", :web, :app, :worker
# server "pagposdev.cloudapp.net", :db

role :app, "p4gp0s.cloudapp.net" # add more servier "pagposx1.cloudapp.net", "pagposx2.cloudapp.net", "pagposx3.cloudapp.net"
role :web, "p4gp0s.cloudapp.net"
# make cap deploy:migrate working fine if in the same vm
# role :db, "pagposdb.cloudapp.net", :primary => true

set :repository, "git@github.com:codeponpon/p4gps4z.git"
set :branch, "master"