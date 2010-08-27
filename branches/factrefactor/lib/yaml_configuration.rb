require 'yaml'
require 'ostruct'

class YamlConfiguration
  class SettingsMissing < StandardError; end
  
  class << self
    @@dir = "#{RAILS_ROOT}/config"
    
    def absolutize(name)
      File.join(@@dir, name + '.yml')
    end
    
    def load(path)
      File.open(path) do |file|
        settings = YAML.load(file)
        settings = settings[RAILS_ENV]
        if settings.nil?
          raise SettingsMissing, "Missing settings for #{RAILS_ENV} environment"
        end
        OpenStruct.new(settings)
      end
    end
  end
end
