require 'xgw/globals'

module Xgw
  class Bootstrap
    class << self
      def init_client
      end
      
      def init_host
        load_host_settings
        Globals.host = Host.new
        Globals.engine = Globals.host.engine
        Globals.storage = Globals.host.engine.storage
        clear_errors
        init_workflows
        register_participants
        init_job_registry
      end
      
      private
      
      def load_host_settings
        Globals.host_settings = Settings.load('ruote_host')
      end
      
      def clear_errors
        Globals.storage.purge_type!('errors')
      end
      
      def init_workflows
        Globals.workflows = ::ClearspringWorkflows.new
        Globals.workflows.define_workflows
      end
      
      def register_participants
        engine = Globals.engine
        Globals.participants.each do |name, instance|
          engine.register_participant(name, instance)
        end
      end
      
      def init_job_registry
        Globals.job_registry = JobRegistry.new
      end
    end
  end
end
