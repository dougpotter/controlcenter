class RuoteBootstrap
  class << self
    def init_client
    end
    
    def init_host
      init_storage
      RuoteGlobals.host = Host.new(RuoteGlobals.storage)
      RuoteGlobals.engine = RuoteGlobals.host.engine
      clear_errors
      init_workflows
      register_participants
      init_job_registry
    end
    
    def init_storage
      if RuoteConfiguration.use_persistent_storage
        require 'ruote/storage/fs_storage'
        storage = Ruote::FsStorage.new('work/xgw')
      else
        require 'ruote/storage/hash_storage'
        storage = Ruote::HashStorage.new
      end
      
      RuoteGlobals.storage = storage
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
      RuoteGlobals.job_registry = job_registry = JobRegistry.new
      
      # for future consideration:
      #  - the call could be placed elsewhere?
      #  - bring worker a few levels up?
      notification_handler = JobRegistryErrorNotificationHandler.new(job_registry)
      RuoteGlobals.host.engine.context.worker.subscribe('error_intercepted', notification_handler)
    end
  end
end