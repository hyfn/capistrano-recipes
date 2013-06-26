# 
# SETTINGS
# 

# Configuration
set :application, "my-wp-blog"

# Stages
set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

# GIT settings
set :scm, :git
set :repository, "git@github.com:/hyfn/#{application}.git" # TODO
set :branch, "master"
set :scm_verbose, true

# Additional deploy settings
set :deploy_via, :remote_cache
set :copy_strategy, :checkout
set :ssh_options, { :forward_agent => true }
set :keep_releases, 3
set :use_sudo, false
set :copy_compression, :bz2

# Disable some Rails stuff
set :normalize_asset_timestamps, false

# 
# TASKS
# 

# Deployment process
after "deploy:update", "deploy:cleanup" 
after "deploy:update", "deploy:set_perms" 
after "deploy:update", "deploy:copy_config"

# Custom deployment tasks
namespace :deploy do

  desc "Update the permissions on the uploads dir"
  task :set_perms, :roles => :app do
    run "chmod -R 777 #{latest_release}/public/wp-content/uploads"

  end

  desc "Copy wp-config-staging.php to wp-config.php"
  task :copy_config, :roles => :app do
    conf = "#{latest_release}/public/wp-config.php"
    run "cp #{conf_template} #{conf}"
  end

  desc "This is here to overide the original :restart"
  task :restart, :roles => :app do
    # do nothing but overide the default
  end
end