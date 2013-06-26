set :domain "staging.#{application}.com"

set :branch, "master"
set :rails_env, "staging"
set :deploy_to, "/var/www/#{domain}"

server domain, :app, :web, :db, :primary => true