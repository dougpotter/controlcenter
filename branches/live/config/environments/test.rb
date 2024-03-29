# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

# Use RSpec
ENV['AUTOFEATURE'] = "true"
ENV['RSPEC'] = "true"

# Manage RubyGems
config.gem "rspec", :lib => false, :version => ">= 1.3.0"
config.gem "rspec-rails", :lib => false, :version => ">= 1.2.0"
config.gem "factory_girl", :lib => false, :version => ">= 1.3.1"
config.gem "cucumber", :lib => false, :version => ">= 0.10.0"
config.gem "webrat", :lib => false, :version => ">=0.7.3"
config.gem "cucumber-rails", :lib => false, :version => ">=0.3.2"
config.gem "database_cleaner", :lib => false, :version => ">=0.6.3"
config.gem "selenium-client", :lib => false, :version => ">=1.2.18"

config.after_initialize do
  DelayedLoad.configure :sass do
    ::Sass::Plugin.options[:never_update] = true
    ::Sass::Plugin.options[:style] = :compressed
  end
end

config.after_initialize do
  PaperclipConfiguration.path_prefix = ":rails_root/tmp/test/attachments"
end

config.after_initialize do
  ApplicationConfiguration.workflow_configuration_class_name = 'Workflow::ReloadableConfiguration'
  ApplicationConfiguration.component_configuration_root = Rails.root.join('config/test')
end
