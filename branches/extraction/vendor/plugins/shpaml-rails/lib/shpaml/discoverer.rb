require 'find'

module Shpaml
  class Discoverer
    def initialize(base)
      @base = base
    end
    
    def find_shpaml_templates
      Find.find(@base) do |path|
        if File.directory?(path)
          basename = File.basename(path)
          if basename == '.svn' || basename == '.git'
            Find.prune
          end
        else
          if path =~ /\.shpaml$/
            yield path
          end
        end
      end
    end
  end
end
