# 
# SETTINGS
# 

# remember to copy public key to server `ssh-copy-id hyfn@servername.com`
# remember to do `ssh git@github.com` from the server first
# need to set up agent forwarding in ssh for the server, see:
#   https://help.github.com/articles/using-ssh-agent-forwarding
# also run ssh-agent to make sure your ssh agent is running

# Configuration
set :application, "example-project"
set :domain, "#{application}.hyfn.com"

# SSH settings
server domain, :app, :web, :db, :primary => true
set :deploy_to, "/var/www/#{domain}"
set :user, "deploy"

# GIT settings
set :scm, :git
set :repository, "git@github.com:hyfn/#{application}.git"
set :scm_username, "my-github-user" # okay to leave blank if it matches your local username
set :branch, "master"
set :scm_verbose, true

# Codeigniter Settings
set :logs_path, "application/logs"
set :cache_path, "application/cache"

# Additional deploy settings
set :deploy_via, :remote_cache
set :copy_strategy, :checkout
set :ssh_options, { :forward_agent => true }
set :keep_releases, 3
set :use_sudo, false
set :copy_compression, :bz2

# Disable some Rails defaults
set :normalize_asset_timestamps, false


# 
# TASKS
# 

# CodeIgniter deployment tasks
after "deploy:update", "deploy:cleanup" 
after "deploy", "deploy:sort_files_and_directories"

# Custom deployment tasks
namespace :deploy do

  desc "This is here to overide the original :restart"
  task :restart, :roles => :app do
    # do nothing but overide the default
  end

  task :finalize_update, :roles => :app do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
    # overide the rest of the default method
  end

  desc "Create additional directories and update permissions"
  task :sort_files_and_directories, :roles => :app do
    # move log files
    if previous_release
      run "mv -f #{previous_release}/#{logs_path} #{latest_release}/#{logs_path}"
    end

    # set permissions
    run "chmod 777 #{latest_release}/#{cache_path}"
    run "chmod 777 #{latest_release}/#{logs_path}"
  end
end