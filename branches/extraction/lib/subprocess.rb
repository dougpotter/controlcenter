module Subprocess
  class CommandFailed < StandardError
    # This attribute is called exitstatus for consistency with Process.wait
    attr_reader :exitstatus
    
    def initialize(message, options={})
      super(message)
      @exitstatus = options[:exitstatus]
    end
  end
  
  BUFSIZE = 16384
  
  # Runs command given in args, which must be a list of arguments.
  # See Kernel#exec for an explanation of args' contents.
  # Standard input, output and error of the command are connected to the ruby
  # process's standard input, output and error.
  # Does not return anything.
  # If the command fails (exit code non-zero), raises CommandFailed.
  # Allowed options:
  #  :env => hash of environment variables to set in spawned process
  def spawn_check(args, options={})
    if pid = fork
      Process.wait(pid)
      if (status = $?.exitstatus) != 0
        raise CommandFailed.new("Command failed with exit status #{status}: #{args.join(' ')}", :exitstatus => status)
      end
      nil
    else
      run_child(args, options)
    end
  end
  module_function :spawn_check
  
  # Runs command given in args, which must be a list of arguments.
  # See Kernel#exec for an explanation of args' contents.
  # Standard input and error of the command are connected to the ruby
  # process's standard input and error.
  # Returs standard output of the command.
  # If the command fails (exit code non-zero), raises CommandFailed.
  # Allowed options:
  #  :env => hash of environment variables to set in spawned process
  def get_output(args, options={})
    pipe_one_output(args, options.merge(:output_stream => STDOUT))
  end
  module_function :get_output
  
  # Runs command given in args, which must be a list of arguments.
  # See Kernel#exec for an explanation of args' contents.
  # Standard input and output of the command are connected to the ruby
  # process's standard input and output.
  # Returs standard error of the command.
  # If the command fails (exit code non-zero), raises CommandFailed.
  # Allowed options:
  #  :env => hash of environment variables to set in spawned process
  def get_error(args, options={})
    pipe_one_output(args, options.merge(:output_stream => STDERR))
  end
  module_function :get_error
  
  private
  
  def pipe_one_output(args, options)
    rd, wr = IO.pipe
    if pid = fork
      wr.close
      output = ''
      while buf = rd.read(BUFSIZE)
        output << buf
      end
      Process.wait(pid)
      if (status = $?.exitstatus) != 0
        if output
          output = "\noutput:\n#{output}"
        end
        raise CommandFailed.new("Command failed with exit status #{status}: #{args.join(' ')}#{output}", :exitstatus => status)
      end
      output
    else
      options[:output_stream].reopen(wr)
      rd.close
      run_child(args, options)
    end
  end
  module_function :pipe_one_output
  
  # Prepares child environment and execs
  def run_child(args, options)
    if env = options[:env]
      env.each do |key, value|
        # convert both keys and values to strings for convenience.
        # if this poses a problem, pass strings in :env in the first place
        ENV[key.to_s] = value.to_s
      end
    end
    exec(*args)
  end
  module_function :run_child
end
