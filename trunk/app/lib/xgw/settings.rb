require 'yaml'

module Xgw
  class Settings < OpenStruct
    class << self
      @@settings_dir = "#{RAILS_ROOT}/config"
      
      def load(name)
        path = File.join(@@settings_dir, name + '.yml')
        File.open(path) do |file|
          settings = YAML.load(file)
          struct = Struct.new(nil, *settings.keys)
          struct.new(*settings.values)
        end
      end
    end
  end
end
