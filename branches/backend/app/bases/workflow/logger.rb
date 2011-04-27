module Workflow
  module Logger
    def self.included(base)
      base.class_eval do
        attr_accessor :logger
      end
    end
    
    private
    
    def initialize_logger(options={})
      @logger = options[:logger] || Workflow.default_logger
    end
  end
end
