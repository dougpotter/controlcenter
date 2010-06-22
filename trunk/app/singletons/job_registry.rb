class JobNotFound < StandardError
end

class Job
  # rjid is nil until start is called
  attr_reader :rjid
  # Possible statuses:
  #
  # :new         Job was submitted
  # :launched    Job was handed to ruote and launched, rjid is set
  # :running     Ruote began running job
  # :success     Job finished successfully
  # :failure     Job finished with an error
  attr_reader :status
  # if status is :failure, exception should contain the exception that
  # caused the failure
  attr_reader :exception
  
  def initialize(name, params)
    @name, @params = name, params
    @status = :new
  end
  
  def set_launched(rjid)
    @rjid = rjid
    @status = :launched
    if RuoteConfiguration.verbose_job_launch
      debug_print "Launched workflow #{@name} -> job #{rjid}"
    end
  end
  
  def set_running
    @status = :running
    if RuoteConfiguration.verbose_job_state
      debug_print "Job #{@rjid} for workflow #{@name} is now running"
    end
  end
  
  def success
    @status = :success
    if RuoteConfiguration.verbose_job_state
      debug_print "Job #{@rjid} for workflow #{@name} is finished"
    end
  end
  
  def failure(exception)
    @status = :failure
    @exception = exception
    if RuoteConfiguration.verbose_job_state
      debug_print "Job #{@rjid} for workflow #{@name} has failed:"
      debug_print "#{exception.class}: #{exception.message}"
      # backtrace is not available in earlier ruote versions
      if exception.backtrace
        debug_print exception.backtrace.join("\n")
      else
        warn "Backtrace is not available, check ruote version"
      end
    end
  end
  
  def wait
    if RuoteConfiguration.verbose_job_wait
      debug_print "Waiting for job #{@rjid} for workflow #{@name}"
    end
    while true do
      if status == :success || status == :failure
        break
      end
      sleep 1
    end
  end
  
  private
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end

# Note: job registry must be threadsafe since muliple threads may be creating
# or looking up jobs concurrently.
class JobRegistry
  def initialize
    @jobs = []
  end
  
  def create_job(name, params)
    job = Job.new(name, params)
    @jobs << job
    job
  end
  
  def jobs
    @jobs
  end
  
  def job_for_rjid(rjid)
    jobs.detect { |job| job.rjid == rjid }
  end
  
  def job_for_rjid!(rjid)
    job = job_for_rjid(rjid)
    unless job
      raise JobNotFound, "No job for rjid #{rjid}"
    end
    job
  end
  
  def wait_for_rjid(rjid)
    job = job_for_rjid!(rjid)
    job.wait
  end
end

class JobRegistryErrorNotificationHandler
  def initialize(job_registry)
    @job_registry = job_registry
  end
  
  # Note: this method must be threadsafe since ruote may call it from multiple
  # threads concurrently.
  def notify(msg)
    action = msg['action']
    unless action == 'error_intercepted'
      raise ArgumentError, "Action must be error_intercepted: #{action}"
    end
    
    rjid = msg['wfid']
    job = @job_registry.job_for_rjid(rjid)
    if job
      # Hopefully this path does not raise exceptions.
      # What should we do if an exception is raised?
      
      # check ruote version
      unless msg['error_class'] && msg['error_message'] && msg['error_backtrace']
        # too old
        $stderr.puts("Your version of ruote is too old: it does not supply useful exception information to error_intercepted subscribers (while handling error_intercepted for job #{rjid})")
        return
      end
      
      # reconstruct original exception
      exception = msg['error_class'].constantize.new(msg['error_message'])
      exception.set_backtrace(msg['error_backtrace'])
      job.failure(exception)
    else
      # Job was not found for ruote's job id.
      # This may happen if job storage is less persistent than ruote storage.
      # Ignore the error, ruote will print it with -d option and/or put the job
      # into error state.
    end
  end
end
