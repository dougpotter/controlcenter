class RuoteBootstrap
  class << self
    def init_client
      init_storage
      # dependency load
      Host
      RuoteGlobals.host = Client.new(RuoteGlobals.storage)
      RuoteGlobals.engine = RuoteGlobals.host.engine
      init_workflows
      register_participants
      init_job_registry
      @initialized = :client
    end
    
    def init_host
      init_storage
      RuoteGlobals.host = Host.new(RuoteGlobals.storage)
      RuoteGlobals.engine = RuoteGlobals.host.engine
      clear_errors
      init_workflows
      register_participants
      init_job_registry
      @initialized = :host
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
    
    # Initializes a client if necessary.
    def soft_init_client
      return if @initialized
      init_client
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
      # note: only hosts have worker, clients do not
      if worker = RuoteGlobals.host.engine.context.worker
        notification_handler = JobRegistryErrorNotificationHandler.new(job_registry)
        worker.subscribe('error_intercepted', notification_handler)
      end
    end
  end
end
