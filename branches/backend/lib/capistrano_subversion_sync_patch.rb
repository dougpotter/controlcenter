require "capistrano/recipes/deploy/scm/subversion"

# Overlay patch for https://capistrano.lighthouseapp.com/projects/8716-capistrano/tickets/46.
# New ticket: https://github.com/capistrano/capistrano/issues/40
# Use class_eval instead of class definition to ensure that we are overriding
# existing sync method.
Capistrano::Deploy::SCM::Subversion.class_eval do
  # Returns the command that will do an "svn switch" to the given
  # revision, for the working copy at the given destination.
  define_method(:sync) do |revision, destination|
    # Subversion supports revision pegging in switch starting with 1.5.0.
    # Before that we can only hope that the path being synced to exists
    # in the currently checked out version.
    scm_min_version = scm_min_version = variable(:scm_min_version)
    if scm_min_version && scm_min_version >= '1.5.0'
      scm :switch, arguments, verbose, authentication, "-r#{revision}", "#{repository}@#{revision}", destination
    else
      check = <<-CMD
        remote_repository=$(
          cd #{destination} &&
          svn info |grep URL: |awk '{print $2}'
        ) &&
        if test "$remote_repository" != "#{repository}"; then
          {
            echo "Cannot switch branches while updating on subversion less than 1.5.0";
            echo "If remote subversion is 1.5.0 or better, set :scm_min_version variable appropriately";
            echo "Remote repository URL: $remote_repository";
            echo "Repository URL being deployed: #{repository}";
          } 1>&2;
          exit 4;
        fi
      CMD
      switch = scm :switch, arguments, verbose, authentication, "-r#{revision}", repository, destination
      "#{check} && #{switch}"
    end
  end
end
