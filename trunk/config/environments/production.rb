# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = false

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

config.after_initialize do
  DelayedLoad.configure :sass do
    ::Sass::Plugin.options[:never_update] = true
    ::Sass::Plugin.options[:style] = :compressed
  end
end

config.after_initialize do
  PaperclipConfiguration.storage = :s3
end

# Object cache
require 'active_support/cache/dalli_store23'
config.cache_store = :dalli_store

require 'action_controller/session/dalli_store'
ActionController::Base.session_store = :dalli_store
