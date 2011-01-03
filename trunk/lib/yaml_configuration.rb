require 'yaml'

class YamlConfiguration
  class SettingsMissing < StandardError; end
  
  class << self
    def absolutize(name)
      root = ApplicationConfiguration.component_configuration_root
      File.join(root, name + '.yml')
    end
    
    def load(path)
      File.open(path) do |file|
        settings = YAML.load(file)
        settings = settings[RAILS_ENV]
        if settings.nil?
          raise SettingsMissing, "Missing settings for #{RAILS_ENV} environment"
        end
        HashWithIndifferentAccess.new(settings)
      end
    end
  end
end
