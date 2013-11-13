server "pagposdev.cloudapp.net", :web, :app, :db, primary: true
server "pagposdev.cloudapp.net", :web, :app, :worker

set :repository, "git@github.com:codeponpon/p4gps4z.git"
set :branch, "staging"

