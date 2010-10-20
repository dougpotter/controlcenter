module Workflow
  module Profiling
    def start_profiling
      # delay loading ruby-prof until profiling is actually needed
      begin
        RubyProf
      rescue NameError
        require 'ruby-prof'
      end
      
      RubyProf.measure_mode = RubyProf::PROCESS_TIME 
      RubyProf.start
    end

    def stop_profiling
      result = RubyProf.stop
      puts 'Saving graph html view'
      printer = RubyProf::GraphHtmlPrinter.new(result)
      printer.print(File.open('profile-output.html', 'w'), :min_percent => 1)
    end

    def with_optional_profiling(enable_profiling)
      if enable_profiling
        start_profiling
        
        begin
          status = yield
        ensure
          begin
            stop_profiling
          rescue Exception => e
            status = ConsoleUi.handle_unhandled_exception(e)
          end
        end
      else
        begin
          status = yield
        rescue Exception => e
          status = ConsoleUi.handle_unhandled_exception(e)
        end
      end
      status
    end
  end
end
