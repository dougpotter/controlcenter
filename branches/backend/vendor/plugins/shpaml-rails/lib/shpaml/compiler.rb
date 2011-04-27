module Shpaml
  class CompilationError < StandardError
  end
  
  class Compiler
    @@python_exec = ['/usr/bin/env', 'python']
    @@aml = File.join(File.dirname(__FILE__), '..', '..', 'aml_erb.py')
    @@aml_generated_warning = false
    
    cattr_accessor :python_exec
    cattr_accessor :aml
    cattr_accessor :aml_generated_warning
    
    def compile_file(input_file, output_file)
      if fork
        Process.wait
        if $?.exitstatus != 0
          raise CompilationError
        end
      else
        cmd_line = build_aml_cmd_line('-o', output_file, input_file)
        exec(*cmd_line)
      end
    end
    
    def compile(options)
      if options[:source]
        input = options[:source]
      elsif options[:file]
        input = File.read(options[:file])
      else
        raise ArgumentError, ":source or :file must be given"
      end
      
      to_aml_rd, to_aml_wr = IO.pipe
      from_aml_rd, from_aml_wr = IO.pipe
      err_aml_rd, err_aml_wr = IO.pipe
      
      if fork
        to_aml_rd.close
        from_aml_wr.close
        err_aml_wr.close
        
        to_aml_wr.write(input)
        to_aml_wr.close
        Process.wait
        if $?.exitstatus != 0
          raise CompilationError, err_aml_rd.read
        end
        output = from_aml_rd.read
      else
        to_aml_wr.close
        from_aml_rd.close
        err_aml_rd.close
        
        $stdin.reopen(to_aml_rd)
        $stdout.reopen(from_aml_wr)
        $stderr.reopen(err_aml_wr)
        
        cmd_line = build_aml_cmd_line
        exec(*cmd_line)
      end
      
      if options[:output_file]
        File.open(options[:output_file], 'w') do |file|
          file.write(output)
        end
        nil
      else
        output
      end
    end
    
    private
    
    def build_aml_cmd_line(*args)
      if (python_exec = self.class.python_exec).is_a?(Array)
        cmd_line = python_exec.dup
      else
        cmd_line = [python_exec]
      end
      
      cmd_line.push(self.class.aml)
      if self.class.aml_generated_warning
        cmd_line << '-g'
      end
      cmd_line += args
    end
  end
end
