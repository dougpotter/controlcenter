task :migrate => 'db:migrate'
task :ci => [ "db:migrate", "spec" ]