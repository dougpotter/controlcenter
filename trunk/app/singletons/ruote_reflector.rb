require 'singleton'

# Ruote Reflector provides introspection services for
# ruote: examining running jobs, scheduled jobs, etc.
class RuoteReflector
  include Singleton
  
  class << self
    delegate :print_status, :to => :instance
  end
  
  # Returns a list of jobs ruote currently is executing.
  # Workflows that do not correspond to known jobs are
  # not returned; use orphan_rjids to get them.
  def jobs
    processes = RuoteGlobals.host.engine.processes
    # todo: how should we handle wfids not corresponding to known jobs?
    job_registry = RuoteGlobals.job_registry
    jobs = []
    processes.map do |process|
      rjid = process.wfid
      job = job_registry.job_for_rjid(rjid)
      jobs << job if job
    end
    jobs
  end
  
  # Returns a list of rjids ruote currently is executing that
  # do not map to any known jobs in the job registry.
  def orphan_rjids
    processes = RuoteGlobals.host.engine.processes
    job_registry = RuoteGlobals.job_registry
    rjids = []
    processes.map do |process|
      rjid = process.wfid
      job = job_registry.job_for_rjid(rjid)
      rjids << rjid unless job
    end
    rjids
  end
  
  # Prints useful statistics about what ruote is doing
  def print_status
    RuoteBootstrap.soft_init_client
    
    jobs = self.jobs
    orphan_rjids = self.orphan_rjids
    
    if jobs.length > 0
      puts "There are #{jobs.length} running jobs:"
    else
      puts 'There are no running jobs.'
    end
    
    if orphan_rjids.length > 0
      puts "There are #{orphan_rjids.length} orphan rjids:"
      orphan_rjids.sort.each do |rjid|
        puts "  #{rjid}"
      end
    end
  end
end
