# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  extra_load_paths = %W(
    #{RAILS_ROOT}/app/bases
    #{RAILS_ROOT}/app/lib
    #{RAILS_ROOT}/app/singletons
    #{RAILS_ROOT}/app/workflows
  )
  
  # Load paths from which classes should not be eagerly loaded due to dependencies
  demand_only_load_paths = %W(
    #{RAILS_ROOT}/app/facades
  )

  config.load_paths += extra_load_paths
  config.load_paths += demand_only_load_paths
  config.eager_load_paths += extra_load_paths

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  
  # Different machines need different sets of dependencies.
  # Please refer to doc/dependencies.txt for a comprehensive treatment
  # of dependencies for each component/use case.
  # Do not add dependencies here unless they are truly required
  # by all use cases.
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  config.frameworks -= [ :active_resource ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  config.after_initialize do
    DelayedLoad.create :sass do
      require 'sass/plugin'
    end
    
    DelayedLoad.create :paperclip do
      require 'paperclip'
      
      # Copied from paperclip's rails/init.rb since it is too much work
      # to work out where that file is and properly load it at runtime.
      # See also:
      # http://www.practicalecommerce.com/blogs/post/438-The-Blurring-Line-Between-Plugins-and-Gems
      require 'paperclip/railtie'
      Paperclip::Railtie.insert
    end
    
    require 'application_configuration'
    require 'paperclip_configuration'
  end
end
