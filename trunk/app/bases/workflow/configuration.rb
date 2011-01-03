module Workflow
  class Configuration
    # Returns parameters from configuration file.
    #
    # Allowed options:
    #
    # :config_path
    def initialize(options={})
      config_path = options[:config_path]
      unless config_path
        raise ArgumentError, ':config_path is required'
      end
      load(config_path)
    end
    
    def dup
      new = super
      new.instance_variable_set('@config_params', @config_params.dup)
      new
    end
    
    def update(options)
      options.each do |key, value|
        unless value.nil?
          @config_params[key] = value
        end
      end
      postprocess_params
      self
    end
    
    def merge(options)
      dup.update(options)
    end
    
    def to_hash
      # typically users expect to_* methods to return copies of data
      @config_params.dup
    end
    
    private
    
    def load(config_path)
      @config_params = YamlConfiguration.load(config_path)
      postprocess_params
    end
    
    # XXX consider refactoring this
    def postprocess_params
      if path = @config_params[:debug_output_path]
        # will also modify the hash
        path.gsub!(/:timestamp\b/, Time.now.strftime('%Y%m%d-%H%M%S'))
      end
      if @config_params[:once]
        @config_params[:lock] = true
      end
      if @config_params[:check_sizes_strictly] || @config_params[:check_sizes_exactly]
        @config_params[:check_sizes] = true
      end
    end
  end
end
