# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false
config.action_view.cache_template_loading = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

config.after_initialize do
  DelayedLoad.configure :sass do
    ::Sass::Plugin.options[:debug_info] = true
  end
end

config.middleware.use 'Shpaml::DevelopmentMiddleware'

config.after_initialize do
  PaperclipConfiguration.path_prefix = ":rails_root/public/attachments"
end
