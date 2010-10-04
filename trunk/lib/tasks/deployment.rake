namespace :compile do
  task :stylesheets => :environment do
    Sass::Plugin.force_update_stylesheets
  end
end
