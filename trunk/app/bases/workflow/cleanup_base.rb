require 'find'
require 'fileutils'

module Workflow
  # Contains methods common to cleanup workflows.
  class CleanupBase < Base
    def cleanup(dir, age, options={})
      threshold = Time.now - age
      Find.find(dir) do |path|
        if %w(.svn .git).include?(File.basename(path))
          Find.prune
        end
        
        next unless FileTest.file?(path)
        
        file_time = determine_file_time(path)
        if file_time < threshold
          if options[:debug]
            debug_print("Remove #{path}")
          end
          
          FileUtils.rm(path)
        end
      end
    end
  end
end
