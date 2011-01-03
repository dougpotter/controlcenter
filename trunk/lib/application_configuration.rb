module ApplicationConfiguration
  class << self
    attr_accessor :workflow_configuration_class_name
  end
  
  self.workflow_configuration_class_name = 'Workflow::Configuration'
end
