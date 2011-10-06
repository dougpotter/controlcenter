namespace :bundler do
  task :install_production do
    exec "bundle install --without test"
  end

  task :install do
    exec "bundle install"
  end
end
