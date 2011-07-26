module Workflow
  module Cache
    def cache
      @@cache ||= {}
    end
  end
end
