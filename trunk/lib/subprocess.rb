module Subprocess
  class CommandFailed < StandardError
  end
  
  BUFSIZE = 16384
  
  # Runs command given in args, which use the same syntax as Kernel#exec.
  # Standard input, output and error of the command are connected to the ruby
  # process's standard input, output and error.
  # Does not return anything.
  # If the command fails (exit code non-zero), raises CommandFailed.
  def spawn_check(*args)
    unless system(*args)
      raise CommandFailed
    end
  end
  module_function :spawn_check
  
  # Runs command given in args, which use the same syntax as Kernel#exec.
  # Standard input and error of the command are connected to the ruby
  # process's standard input and error.
  # Returs standard output of the command.
  # If the command fails (exit code non-zero), raises CommandFailed.
  def get_output(*args)
    rd, wr = IO.pipe
    if pid = fork
      wr.close
      output = ''
      while buf = rd.read(BUFSIZE)
        output << buf
      end
      Process.wait(pid)
      if $?.exitstatus != 0
        raise CommandFailed
      end
      output
    else
      $stdout.reopen(wr)
      rd.close
      exec(*args)
    end
  end
  module_function :get_output
end
