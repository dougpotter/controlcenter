require 'rubygems'
require 'singleton'
require 'delegate'
require 'ruote'
require 'xgw/shared_storage'

module Xgw
  class Director
    attr_reader :engine
    
    def launch(name, input)
      job = Globals.job_registry.create_job(name, input)
      pdef = Globals.workflows.get(name)
      rjid = @engine.launch(pdef, :input => input)
      job.set_launched(rjid)
      job
    end
    
    def print_last_error
      error = @storage.ruote_storage.get_many('errors')[-1]
      if error
        puts error['message']
        puts error['trace']
      end
    end
  end

  class Client < Director
    def initialize
      @storage = SharedStorage.new
      @engine = Ruote::Engine.new(@storage.ruote_storage)
    end
  end

  class Host < Director
    def initialize
      @storage = SharedStorage.new
      @worker = Ruote::Worker.new(@storage.ruote_storage)
      @engine = Ruote::Engine.new(@worker)
    end
    
    def run_inline(name, input)
      job = launch(name, input)
      job.wait
    end
  end
end
