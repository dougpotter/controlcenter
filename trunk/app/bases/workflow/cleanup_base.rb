require 'find'
require 'fileutils'

module Workflow
  # Contains methods common to cleanup workflows.
  class CleanupBase < Base
    expose_params :channel
    
    private
    
    # Deletes old files in directory dir.
    #
    # Options are as follows:
    #
    # :age (seconds) - files labeled older than this number of seconds
    #   are candidates for removal, subject to :mtime_hold option.
    #   The age option is required.
    # :mtime_hold (seconds) - files whose modification time is newer than
    #   this number of seconds ago will not be removed regardless of
    #   labeled age.
    #   Pass 0 to disable this feature.
    #   If not given, :mtime_hold is taken to be 1/2 of :age.
    def cleanup_dir(dir, options)
      unless age = options[:age]
        raise ArgumentError, ":age must be given in arguments"
      end
      mtime_hold = options[:mtime_hold] || age / 2
      
      now = Time.now
      age_threshold = now - age
      if mtime_hold == 0
        hold_threshold = nil
      else
        hold_threshold = now - mtime_hold
      end
      
      # if dir is a symlink, then on linux File.find(dir) only yields dir.
      # Resolve symlinks manually here for dir.
      dir = resolve_symlink(dir)
      
      Find.find(dir) do |path|
        if %w(.svn .git).include?(File.basename(path))
          Find.prune
        end
        
        next unless FileTest.file?(path)
        
        file_time = determine_file_time(path)
        next if file_time >= age_threshold
        
        if hold_threshold
          mtime = determine_file_time(path)
          next if mtime >= hold_threshold
        end
        
        if options[:only_verified]
          unless data_provider_file_verified?(path)
            if options[:debug]
              debug_print("File not verified, not removing: #{path}")
            end
            next
          end
        end
        
        if options[:debug] || options[:pretend]
          debug_print("Remove #{path}")
        end
        
        unless options[:pretend]
          FileUtils.rm(path)
        end
      end
    end
    
    def resolve_symlink(dir)
      while File.symlink?(dir)
        target = File.readlink(dir)
        if target.starts_with?('/')
          dir = target
        else
          dir = File.join(File.dirname(dir), target)
        end
      end
      dir
    end
  end
end
