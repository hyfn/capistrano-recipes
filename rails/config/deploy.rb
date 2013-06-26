# set up bundler (may not be necessary any more)
require 'bundler/capistrano'
require 'new_relic/recipes'

# set up cron
set :whenever_environment, defer { stage }
set :whenever_identifier, defer { "#{application}_#{stage}" }
set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

# set up multistage
set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

# delayed job
require "delayed/recipes" 
before "deploy:restart", "delayed_job:stop"
after  "deploy:restart", "delayed_job:start"
after "deploy:stop",  "delayed_job:stop"
after "deploy:start", "delayed_job:start"

# app name
set :application, "my-rails-app" # change me

# send a hipchat notification
require 'hipchat/capistrano'
set :hipchat_token, "your-hipchat-token"
set :hipchat_room_name, application
set :hipchat_announce, false

# sphinx
require 'thinking_sphinx/deploy/capistrano'
after 'deploy:setup', 'thinking_sphinx:shared_sphinx_folder'
after 'deploy:migrate', 'thinking_sphinx:rebuild'
after 'deploy:update_code', 'thinking_sphinx:rebuild'
after  "deploy:restart", "thinking_sphinx:restart"

ssh_options[:forward_agent] = true


set :repository,  "git@github.com:hyfn/#{application}.git"

set :use_sudo, false

set :scm, :git
set :scm_verbose, true
set :deploy_via, :remote_cache
set :keep_releases, 3
  
set :user, 'deploy'

after "deploy", "deploy:cleanup"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
  
desc <<-DESC
  Run a rake task on the server. Use the TASK variable to specify the name.

  Sample usage:

    $ cap rake TASK='db:migrate'
DESC
task :raketask do
  tsk = ENV["TASK"] || ""
  abort "Please specify a task to execute on the remote servers (via the TASK environment variable)" if tsk.empty?
  run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{tsk}"
end

desc <<-DESC
  Seed remote database

  Sample usage:

    $ cap seed_remote
DESC
task :seed_remote do
  tsk = 'scholarships:reset deadlines:institutions:import deadlines:states:import --trace'
  run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{tsk}"
end
namespace :deploy do
  desc "Run rake reset"
  task :reset do
    run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} reset"
  end
end

require './config/boot'
require 'airbrake/capistrano'