require 'shpaml/compiler'

module Shpaml
  class DevelopmentMiddleware
    def initialize(app)
      @app = app
      base = File.join(Rails.root, 'app', 'views')
      @discoverer = Shpaml::Discoverer.new(base)
      @compiler = Shpaml::Compiler.new
    end
    
    def call(env)
      compile_shpaml_templates
      @app.call(env)
    end
    
    def compile_shpaml_templates
      @discoverer.find_shpaml_templates do |path|
        compile_shpaml_template_if_stale(path)
      end
    end
    
    def compile_shpaml_template_if_stale(source_path)
      dest_path = source_path.sub(/\.shpaml$/, '')
      if source_path == dest_path
        raise ArgumentError, "Cannot compile a template to itself"
      end
      
      if File.exist?(dest_path)
        source_mtime = File.mtime(source_path)
        dest_mtime = File.mtime(dest_path)
        recompile = source_mtime > dest_mtime
      else
        recompile = true
      end
      
      if recompile
        # todo:
        # 1. add generated file note
        # 2. add source timestamp into destination
        @compiler.compile_file(source_path, dest_path)
      end
    end
  end
end
