require 'yaml'

class WorkflowParameters
  class << self
    @@dir = "#{RAILS_ROOT}/config"
    
    def absolutize(name)
      File.join(@@dir, name + '.yml')
    end
    
    def load(path)
      File.open(path) do |file|
        settings = YAML.load(file)
        struct = Struct.new(nil, *settings.keys)
        struct.new(*settings.values)
      end
    end
  end
end
