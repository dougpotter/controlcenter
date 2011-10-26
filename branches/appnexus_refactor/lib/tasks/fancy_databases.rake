rename_task('db:test:purge', 'db:test:purge:original')

task 'db:test:purge' => :environment do
  abcs = ActiveRecord::Base.configurations
  purge_script = File.join(File.dirname(__FILE__), "../../db/purge_#{abcs['test']['adapter']}.rb")
  if File.exist?(purge_script)
    load(purge_script)
  else
    Rake::Task['db:test:purge:original'].invoke
  end
end
