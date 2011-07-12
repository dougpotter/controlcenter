namespace :bundler do
  task :install do
    exec "bundle install --without test"
  end
end
