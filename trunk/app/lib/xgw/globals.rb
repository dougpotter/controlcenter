module Xgw
  class Globals
    class << self
      attr_accessor :host
      attr_accessor :storage
      attr_accessor :client
      attr_accessor :workflows
      attr_accessor :engine
      attr_accessor :job_registry
      attr_accessor :host_settings
      
      def participants
        @participants ||= {}
      end
    end
  end
end
