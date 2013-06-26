set :domain "#{application}.com"

app_servers = [ 'ec2-1.compute-1.amazonaws.com', 
                'ec2-2.compute-1.amazonaws.com',
                'ec2-3.compute-1.amazonaws.com', ]

role :db, 'rds.amazonaws.com', primary: true
# run cron tasks only on the first app server
role :cron, app_servers[0]
role :app, *app_servers
role :web, *app_servers
set :whenever_roles, :cron

set :branch, "master"
set :rails_env, "production"
set :deploy_to, "/var/www/#{domain}"