require 'rake/rdoctask'

Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.template = ENV['template'] if ENV['template']
  rdoc.title    = ENV['title'] || "Delayed Load Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :doc
