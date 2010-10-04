namespace :compile do
  task :stylesheets => :environment do
    Sass::Plugin.update_stylesheets
  end
end
