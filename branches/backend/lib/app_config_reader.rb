require 'ostruct'
require 'yaml'

class AppConfigReader
  class ConfigLoadError < StandardError; end
  
  class ConfigFileNotExists < ConfigLoadError; end
  
  class EnvConfigNotExists < ConfigLoadError; end
  
  def initialize(component)
    @component = component
  end
  
  def apply!(config_mod=nil)
    config_mod ||= "#{@component.camelize}Configuration".constantize
    config_path = "#{RAILS_ROOT}/config/#{@component}.yml"
    if File.exist?(config_path)
      all_settings = YAML.load_file(config_path)
      env_settings = HashWithIndifferentAccess.new(all_settings)[RAILS_ENV]
      if env_settings
        env_settings.each do |key, value|
          config_mod.send("#{key}=", value)
        end
      else
        raise EnvConfigNotExists, "No #{@component} settings found for #{RAILS_ENV} environment"
      end
    else
      raise ConfigFileNotExists, "#{config_path} does not exist"
    end
  end
end
