# capistrano <3 symfony

# 
# SETTINGS
# 

# Configuration
set :application, "symfony-app"

# Stages
set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

# SSH settings
# in config/deploy/(staging|production).rb

# GIT settings
set :scm, :git
set :repository, "git@github.com:/hyfn/#{application}.git"
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
# after "deploy:update", "deploy:cleanup" 
after "deploy:update", "deploy:set_perms" 
after "deploy:update", "deploy:symlink_shared"

# Custom deployment tasks
namespace :deploy do

  desc "Create and 777ify uploads, cache, log dirs"
  task :set_perms, :roles => :app do

    # mkdir -p and chmod 777 all this shit
    writeables = %w( cache/
                     web/assets/.sass-cache/
                     web/assets/admin/.sass-cache/
                     web/assets/uploads/
                     .sass-cache
                     web/files/ )
    
    writeables.each do |dir| 
      run "mkdir -p #{latest_release}/#{dir}"
      run "chmod -R 777 #{latest_release}/#{dir}"
    end
  end

  desc "Symlinks config and uploads and logs from shared dir into project"
  task :symlink_shared, :roles => :app do
    db_conf = "config/databases.yml"
    run "ln -nfs #{shared_path}/#{db_conf} #{release_path}/#{db_conf}" 
    run "ln -nfs #{shared_path}/log #{release_path}/log" 
    run "ln -nfs #{shared_path}/uploads #{release_path}/web/assets/uploads" 
  end

  desc "This is here to overide the original :restart"
  task :restart, :roles => :app do
    # do nothing but overide the default
  end
end