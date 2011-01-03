module ApplicationConfiguration
  class << self
    attr_accessor :workflow_configuration_class_name
    
    attr_accessor :component_configuration_root
  end
  
  self.workflow_configuration_class_name = 'Workflow::Configuration'
  self.component_configuration_root = Rails.root.join('config')
end
