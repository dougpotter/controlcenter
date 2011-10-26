# make Timeout.timeout call SystemTimer.timeout_after.
# should only be necessary for ruby 1.8.
# see http://ph7spot.com/musings/system-timer

require 'system_timer'
require 'timeout'

module Timeout
  def timeout(time, klass=nil, &block)
    SystemTimer.timeout_after(time, &block)
  end
  
  module_function :timeout
end
