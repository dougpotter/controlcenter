namespace :compile do
  task :stylesheets => :environment do
    ::LazySass.load!
    ::Sass::Plugin.force_update_stylesheets
  end
end
