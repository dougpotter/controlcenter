namespace :compile do
  task :stylesheets => :environment do
    DelayedLoad.load_sass!
    ::Sass::Plugin.force_update_stylesheets
  end
end
