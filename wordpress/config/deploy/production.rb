set :domain, "#{application}.com"
server domain, :app, :web, :db, :primary => true
set :deploy_to, "/var/www/#{domain}"
set :user, "deploy"

set :conf_template, "#{latest_release}/public/wp-config-staging.php"