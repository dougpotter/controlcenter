module Subprocess
  class CommandFailed < StandardError
  end
  
  def spawn_check(*args)
    unless system(*args)
      raise CommandFailed
    end
  end
  module_function :spawn_check
end
