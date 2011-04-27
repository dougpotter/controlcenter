module Workflow
  module ConfigurationRetrieval
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end
    
    module ClassMethods
      def default_config_path
        config_file_name = data_provider_name.underscore.gsub(' ', '_')
        YamlConfiguration.absolutize("workflows/#{config_file_name}")
      end
      
      def configuration(options={})
        default_options = {:config_path => default_config_path}
        config_cls = ApplicationConfiguration.workflow_configuration_class_name.constantize
        config_cls.new(default_options.update(options))
      end
    end
  end
end
