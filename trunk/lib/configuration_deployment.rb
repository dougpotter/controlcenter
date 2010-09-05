# Usage:
#
# define_configuration_tasks(:appwall, %w(appwall.yml))
#
# This will create capistrano tasks:
#
# config:appwall:push
# config:appwall:symlink
#
# The push task uploads configuration files from local machine to the
# remote servers. If there is a production version of the file, it will be
# used, otherwise the file itself is used. For the above example, the following
# paths will be tried:
#
# config/appwall.yml.production
# config/appwall.yml
#
# The first one of these paths that exists will be uploaded to
# #{shared_path}/config/appwall.yml.
#
# The symlink task symlinks the configuration files from shared path to
# release path's config directory. In our example,
# #{shared_path}/config/appwall.yml will be symlinked to
# #{release_path}/config/appwall.yml.
#
# Symlink task is arranged to run automatically after deploy:update_code task.
#
# config_files is an array of configuration files. If multiple files are
# given, each is processed independently from others.
def define_configuration_tasks(namespace, config_files)
  namespace(:config) do
    namespace(namespace) do
      desc("Push new #{namespace} configuration")
      task(:push) do
        push_config_files(config_files)
      end
      
      desc("Make symlink for #{namespace} configuration")
      task(:symlink) do
        symlink_config_files(config_files)
      end
    end
  end
  
  after 'deploy:update_code', "config:#{namespace}:symlink"
end

def push_config_files(paths)
  paths = resolve_config_file_paths(paths)
  paths.each do |local_path, remote_shared_path, remote_release_path|
    put File.read(local_path), remote_shared_path
  end
end

def symlink_config_files(paths)
  paths = resolve_config_file_paths(paths)
  paths.each do |local_path, remote_shared_path, remote_release_path|
    run "ln -nfs #{remote_shared_path} #{remote_release_path}"
  end
end

def resolve_config_file_paths(shortpaths)
  shortpaths.map do |shortpath|
    basepath = File.join(File.dirname(__FILE__), '../config', shortpath)
    remote_shared_path = File.join(shared_path, 'config', shortpath)
    remote_release_path = File.join(release_path, 'config', shortpath)
    if File.exist?(prodpath = basepath + '.production')
      [prodpath, remote_shared_path, remote_release_path]
    else
      [basepath, remote_shared_path, remote_release_path]
    end
  end
end
