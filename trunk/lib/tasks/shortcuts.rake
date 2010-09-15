task :migrate => 'db:migrate'
task :ci => [ "db:migrate", "spec" ]

# Override default rake task to compile templates before running specs.
# This must happen after rspec tasks get defined (in other words, after
# rspec.rake is loaded).
Rake.application.instance_variable_get('@tasks').delete('default')
task :default => %w(shpaml:compile spec)
