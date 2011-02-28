module Workflow
  module DebugPrint
    private
    
    def debug_print(msg)
      logger.debug(self.class.name) { msg }
    end
  end
end
