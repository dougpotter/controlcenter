require "capistrano/recipes/deploy/scm/subversion"

# Overlay patch for https://capistrano.lighthouseapp.com/projects/8716-capistrano/tickets/46.
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
      scm :switch , arguments, verbose, authentication, "-r#{revision}", "#{repository}@#{revision}", destination
    else
      scm :switch , arguments, verbose, authentication, "-r#{revision}", repository, destination
    end
  end
end
