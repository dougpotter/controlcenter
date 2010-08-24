require 'rubygems'
require 'singleton'
require 'delegate'
require 'ruote'

class Director
  attr_reader :engine
  
  def launch(name, input)
    job = RuoteGlobals.job_registry.create_job(name, input)
    pdef = RuoteGlobals.workflows.get(name)
    rjid = @engine.launch(pdef, :input => input)
    job.set_launched(rjid)
    job
  end
  
  def print_last_error
    error = @engine.storage.get_many('errors')[-1]
    if error
      puts error['message']
      puts error['trace']
    end
  end
end

class Client < Director
  def initialize(storage)
    @engine = Ruote::Engine.new(storage)
  end
end

class Host < Director
  def initialize(storage)
    @worker = Ruote::Worker.new(storage)
    @engine = Ruote::Engine.new(@worker)
  end
  
  def run_inline(name, input)
    job = launch(name, input)
    job.wait
  end
end
