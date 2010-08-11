# =============================================================================
# REQUIRED PLUGINS
# =============================================================================
require 'vendor/plugins/capistrano_mailer/lib/capistrano_mailer'

# =============================================================================
# CAP VARIABLES
# =============================================================================
# The name of your application. Used for directory and file names associated with the application.
set :application, ENV["XGCC_APPLICATION"] || "control.xgraph.net"
set :host, application

# Primary domain name of your application. Used as a default for all server roles.
set :domain, application

# Login user for ssh.
set :user, "www"
set :runner, user

# Rails environment. Used by application setup tasks and migrate tasks.
set :rails_env, "production"
set :rake, "rake"

# Target directory for the application on the web and app servers.
set :deploy_to, "/var/www/apps/#{ENV["XGCC_DEPLOY_DIR"] || application}"
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
role :web, domain
role :app, domain, :migration_czar => true
role :db,  domain, :primary => true

# =============================================================================
# SCM OPTIONS
# =============================================================================
set :scm, :subversion
set :deploy_via, :remote_cache

# URL of your source repository.
set :repository, "https://xgraph@dev.xgraph.net/svn/xgraph/xgcc/trunk"
#set :branch, (ENV['BRANCH']||"master")

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
# APPWALL CONFIGURATION
# =============================================================================
after "deploy:update_code", "appwall:symlink" 

namespace :appwall do

  desc "Push new appwall configuration" 
  task :push do
    put File.read(File.join(File.dirname(__FILE__), 'appwall.yml')),
      File.join(shared_path, 'config', 'appwall.yml')
  end
  
  desc "Make symlink for appwall yaml" 
  task :symlink do
    run "ln -nfs #{shared_path}/config/appwall.yml #{release_path}/config/appwall.yml" 
  end
end

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
  task :seed, :roles=> :app, :only => {:migration_czar => true }  do
    run "cd #{current_release}; " + 
      "rake RAILS_ENV=#{rails_env} db:seed_fu > /dev/null"
  end
end

# =============================================================================
# DEPLOY SECTION
# =============================================================================
namespace :deploy do
  task :default do
    transaction do
      update_code
      web.disable
      symlink
      migrate
      restart_web
    end
    web.enable

    # Don't use sudo for cleanup.  This takes a bit longer than using sudo, but
    # it's not a good idea to give passwordless `sudo rm` permissions to anyone.
    set :use_sudo, false
    cleanup
    set :use_sudo, true
  end

  desc "Install gems required by application as defined with config.gem"
  task :check_gems, :roles=> :app do
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} gems:install"
  end

  task :restart_web do
    run "thin restart -C /etc/thin/#{application}.yml"
  end

  # Monkey patch for deploy migrate to run only on migration czar, cut some flexibility
  task :migrate, :roles => :app, :only => {:migration_czar => true } do
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} db:migrate"
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
    puts `svn update > /dev/null && svn log -r #{current_revision}:HEAD | grep '#[0-9]' | sort | uniq`.gsub(/(#[0-9]+)/){|match|
      '<a href="https://dev.xgraph.net/trac/ticket/'+match.gsub(/[^0-9]/,"")+'">'+match+'</a>'
    }.gsub(/\n/,"<br />\n")
  end

  task :changes do
    puts `svn update > /dev/null && svn log -r #{current_revision}:HEAD | grep '#[0-9]' | sort | uniq`
  end
end

namespace :deploy do
  after "deploy", "deploy:notify" if host == "control.xgraph.net" && rails_env == "production"
  after "deploy:fast", "deploy:notify" if host == "control.xgraph.net" && rails_env == "production"

  desc "Send email notification of deployment"
  task :notify do
    show.me
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
                :tickets => `svn update > /dev/null && svn log -r #{previous_revision}:HEAD | grep '#[0-9]' | sort | uniq`.gsub(/(#[0-9]+)/){|match|
                            '<a href="https://dev.xgraph.net/trac/ticket/'+match.gsub(/[^0-9]/,"")+'">'+match+'</a>'
                            }.gsub(/\n/,"<br />\n")
          ],[   # Send some more custom vars you've setup in your deploy.rb to be sent out with the notification email!
                # will be rendered as a section of the email called 'Extra Information'
          ]
        )
  end
end

