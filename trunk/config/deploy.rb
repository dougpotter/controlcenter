# =============================================================================
# CAP VARIABLES
# =============================================================================
# The name of your application. Used for directory and file names associated with the application.
set :application, ENV["XGCC_APPLICATION"] || "control.xgraph.net"
set(:host) { ENV["XGCC_HOST"] || application }

# Primary domain name of your application. Used as a default for all server roles.
set(:domain) { host }

# Login user for ssh.
set :user, "www"
set :runner, user

# Experimenting with not using sudo.
set :use_sudo, false

# Rails environment. Used by application setup tasks and migrate tasks.
set :rails_env, "production"
set :rake, "rake"
set :thin_config, "/etc/thin/#{application}.yml"

# Target directory for the application on the web and app servers.
set(:deploy_to) { "/var/www/apps/#{ENV["XGCC_DEPLOY_DIR"] || application}" }
set :keep_releases, 5
set :shared_children, %w{config log pids tmp system}

#INFO: Intentionally disabled
# Automatically symlink these directories from curent/public to shared/public.
# set :app_symlinks, %w{photo document asset}

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

# Modify these values to execute tasks on a different server.
role(:web) { domain }
role(:app, :migration_czar => true) { domain }
role(:db, :primary => true) { domain }

# =============================================================================
# SCM OPTIONS
# =============================================================================
set :scm, :subversion

# Specify minimum version of scm in use. This should be set to the smallest
# of versions installed on the machine running capistrano commands and the
# machines which are deployment targets.
#set :scm_min_version, '1.6.0'

# User specification.
# Specifying scm_username affects both local and remote operations, thus
# deploying human users must enter two sets of credentials on their machines.
# On the other hand, capistrano does not recognize subversion username
# prompts, so without specifying username here a manual login and checkout
# is required on each remote machine to populate subversion auth cache.
set :scm_username, 'xgraph'
set :scm_auth_cache, true

set :deploy_via, :remote_cache

# URL of your source repository.
set(:repository) do
  if branch == 'trunk' || branch.index('/')
    path = branch
  else
    path = "branches/#{branch}"
  end
  # Note: user@ specification here is ignored by subversion in some/all cases
  "https://dev.xgraph.net/svn/xgraph/controlcenter/#{path}"
end
# Allowed branch specifications:
#
# A branch specification without slashes is taken to be a branch name, and
# branches/ is prepended to the name to obtain repository path.
# Trunk is treated specially, it corresponds to trunk in repository.
# A branch specification containing a slash is taken to mean path in repository.
#
# Examples:
#
# trunk => trunk
# live => branches/live
# branches/live => branches/live
set :branch, ENV['BRANCH'] || "live"

#if we use submodules
#set :git_enable_submodules, 1

#to use local key for git repos
#set :ssh_options, { :forward_agent => true }

# =============================================================================
# SSH OPTIONS
# =============================================================================
#ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
ssh_options[:port] = 22

# =============================================================================
# DEPLOYMENT TARGETS
# =============================================================================

task :qa do
  set :application, 'control.qa.xgraph.net'
  set :branch, 'trunk'
end

# Environment for testing deployment - a dedicated user account on QA
task :deploy_test do
  set :application, 'control.qa.xgraph.net'
  set :user, 'deploytest'
  set :deploy_to, "/home/#{user}/deployroot"
  set :use_sudo, false
end

# =============================================================================
# APPWALL CONFIGURATION
# =============================================================================

define_configuration_tasks(:appwall, %w(appwall.yml))

# =============================================================================
# AWS CONFIGURATION
# =============================================================================

define_configuration_tasks(:aws, %w(aws.yml))

# =============================================================================
# WORKFLOWS CONFIGURATION
# =============================================================================

define_configuration_tasks(:workflows, %w(workflows/clearspring.yml))

# =============================================================================
# SCHEDULE CONFIGURATION
# =============================================================================

define_configuration_tasks(:schedule, %w(schedule.rb))

# =============================================================================
# DATABASE TASKS
# =============================================================================
after "deploy:update_code", "db:symlink"

namespace :db do

  desc "Push new database yaml"
  task :push do
    put File.read(File.join(File.dirname(__FILE__), 'database.yml')),
      File.join(shared_path, 'config', 'database.yml')
  end
  
  desc "Make symlink for database yaml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Seed database"
  task :seed, :roles => :app, :only => {:migration_czar => true}  do
    run "cd #{current_release}; " +
      "rake RAILS_ENV=#{rails_env} db:seed_fu > /dev/null"
  end
end

# =============================================================================
# COMPILATION
# =============================================================================

# Important: shpaml compiler loads environment and therefore compiling
# templates has to follow db symlinking
after "deploy:update_code", "deploy:compile"

namespace :deploy do
  namespace :compile do
    task :default do
      shpaml
      stylesheets
    end
    
    task :shpaml do
      run "cd #{release_path} && rake RAILS_ENV=#{rails_env} shpaml:compile"
    end
    
    task :stylesheets do
      run "cd #{release_path} && rake RAILS_ENV=#{rails_env} compile:stylesheets"
    end
  end
end

# =============================================================================
# DEPLOY SECTION
# =============================================================================
namespace :deploy do
  desc 'Deploys complete control center package'
  task :default do
    transaction do
      update_code
      web.disable
      symlink
      migrate
      web.restart
    end
    web.enable

    # Don't use sudo for cleanup.  This takes a bit longer than using sudo, but
    # it's not a good idea to give passwordless `sudo rm` permissions to anyone.
    set :use_sudo, false
    cleanup
    set :use_sudo, true
  end
  
  desc 'Deploys workflow-related parts only (no web application component)'
  task :workflow do
    transaction do
      update_code
      symlink
      # Note that if we are using a single database for web application
      # instance and workflow instance, this will migrate the web application
      # instance also
      migrate
    end
  end

  desc "Install gems required by application as defined with config.gem"
  task :check_gems, :roles => :app do
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} gems:install"
  end

  # Monkey patch for deploy migrate to run only on migration czar, cut some flexibility
  task :migrate, :roles => :app, :only => {:migration_czar => true} do
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} db:migrate"
  end

  namespace :web do
    desc 'Start thins'
    task :start do
      run "thin start -C #{thin_config}"
    end
    
    desc 'Stop thins'
    task :stop do
      run "thin stop -C #{thin_config}"
    end
    
    desc 'Restart thins'
    task :restart do
      run "thin restart -C #{thin_config}"
    end
  end
end


# =============================================================================
# NOTIFIER
# =============================================================================
namespace :show do
  task :me do
    set :task_name, task_call_frames.first.task.fully_qualified_name
    puts "Running #{task_name} task"
  end

  task :tickets do
    puts `svn log https://dev.xgraph.net/svn/xgraph/controlcenter -r #{current_revision}:HEAD | grep '#[0-9]' | sort | uniq`.gsub(/(#[0-9]+)/){|match|
      '<a href="https://dev.xgraph.net/trac/ticket/'+match.gsub(/[^0-9]/,"")+'">'+match+'</a>'
    }.gsub(/\n/,"<br />\n")
  end

  task :changes do
    puts `svn log https://dev.xgraph.net/svn/xgraph/controlcenter -r #{current_revision}:HEAD | grep '#[0-9]' | sort | uniq`
  end
end

namespace :deploy do
  after :deploy do
    if host == "control.xgraph.net" && rails_env == "production"
      notify
    end
  end

  desc "Send email notification of deployment"
  task :notify do
    show.me
    if ENV['XGCC_NO_CAP_MAILER'].nil? || !%w(1 yes true).include?(ENV['XGCC_NO_CAP_MAILER'].downcase)
      mailer.send([#only send variables you want to be in the email
                  :rails_env => rails_env,
                  :host => host,
                  :task_name => task_name,
                  :application => application,
                  :repository => repository,
                  :scm => scm,
                  :deploy_via => deploy_via,
                  :deploy_to => deploy_to,
                  :revision => revision,
                  :real_revision => real_revision,
                  :release_name => release_name,
                  :version_dir => version_dir,
                  :shared_dir => shared_dir,
                  :current_dir => current_dir,
                  :releases_path => releases_path,
                  :shared_path => shared_path,
                  :current_path => current_path,
                  :release_path => release_path,
                  :releases => releases,
                  :current_release => current_release,
                  :previous_release => previous_release,
                  :current_revision => current_revision,
                  :latest_revision => latest_revision,
                  :previous_revision => previous_revision,
                  :run_method => run_method,
                  :latest_release => latest_release,
            ],[   # Send some custom vars you've setup in your deploy.rb to be sent out with the notification email!
                  # will be rendered as a section of the email called 'Release Data'
                  :tickets => `svn log https://dev.xgraph.net/svn/xgraph/controlcenter -r #{previous_revision}:HEAD | grep '#[0-9]' | sort | uniq`.gsub(/(#[0-9]+)/){|match|
                              '<a href="https://dev.xgraph.net/trac/ticket/'+match.gsub(/[^0-9]/,"")+'">'+match+'</a>'
                              }.gsub(/\n/,"<br />\n")
            ],[   # Send some more custom vars you've setup in your deploy.rb to be sent out with the notification email!
                  # will be rendered as a section of the email called 'Extra Information'
            ]
          )
    else
      puts "Capistrano mailer disabled via XGCC_NO_CAP_MAILER"
    end
  end
end

# =============================================================================
# SCHEDULED TASKS
# =============================================================================
after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :app, :only => {:migration_czar => true} do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end

# =============================================================================
# HOUSEKEEPING
# =============================================================================
namespace :deploy do
  desc "Remove repository cache (use when switching branches or reorganizing repository)"
  task :remove_repository_cache do
    cache_path = fetch(:repository_cache, 'cached-copy')
    run "rm -rf #{shared_path}/#{cache_path}"
  end
end
