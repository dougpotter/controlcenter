task :migrate => 'db:migrate'
task :ci => %W(db:migrate shpaml:compile bundle\sinstall spec cucumber db:migrate:cucumber)

# Override default rake task to compile templates before running specs.
# This must happen after rspec tasks get defined (in other words, after
# rspec.rake is loaded).
Rake.application.instance_variable_get('@tasks').delete('default')
task :default => %w(shpaml:compile spec)


# migrate the cucumber database 
namespace :db do
  namespace :migrate do
    task :cucumber do
      RAILS_ENV = 'cucumber'
      Rake::Task['db:migrate'].invoke
    end
  end
end
