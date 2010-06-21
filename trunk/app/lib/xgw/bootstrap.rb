module Xgw
  class Bootstrap
    class << self
      def init_client
      end
      
      def init_host
        RuoteGlobals.host = Host.new
        RuoteGlobals.engine = RuoteGlobals.host.engine
        RuoteGlobals.storage = RuoteGlobals.host.engine.storage
        clear_errors
        init_workflows
        register_participants
        init_job_registry
      end
      
      private
      
      def clear_errors
        RuoteGlobals.storage.purge_type!('errors')
      end
      
      def init_workflows
        RuoteGlobals.workflows = ::ClearspringWorkflows.new
        RuoteGlobals.workflows.define_workflows
      end
      
      def register_participants
        engine = RuoteGlobals.engine
        RuoteGlobals.participants.each do |name, instance|
          engine.register_participant(name, instance)
        end
      end
      
      def init_job_registry
        RuoteGlobals.job_registry = JobRegistry.new
      end
    end
  end
end
