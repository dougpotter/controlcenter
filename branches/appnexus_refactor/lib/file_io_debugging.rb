module FileIoDebugging
  module FileInstanceMixin
    def self.included(base)
      base.class_eval do
        alias_method_chain :write, :debugging
      end
    end
    
    def write_with_debugging(*args)
      begin
        write_without_debugging(*args)
      rescue IOError
        puts "IOError"
        sleep 1
        raise
      end
    end
  end
  
  module FileClassMixin
    def self.included(base)
      base.class_eval do
        alias_method_chain :open, :debugging
      end
    end
    
    def open_with_debugging(*args)
      puts "Open #{args.join(' : ')}"
      begin
        if block_given?
          open_without_debugging(*args) do |file|
            class << file
              include FileInstanceMixin
            end
            yield file
          end
        else
          f = open_without_debugging(*args)
          class << f
            include FileInstanceMixin
          end
          f
        end
      rescue IOError
        puts "IOError in open"
        raise
      end
    end
  end
  
  def activate!
    class << File
      include FileClassMixin
    end
  end
  module_function :activate!
end
