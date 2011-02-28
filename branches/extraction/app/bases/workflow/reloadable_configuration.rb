module Workflow
  class ReloadableConfiguration < Configuration
    def initialize(options={})
      super
      @options = options
    end
    
    def reload!
      load(@options[:config_path])
    end
  end
end
