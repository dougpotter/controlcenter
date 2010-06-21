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
    if Xgw::Globals.host_settings.verbose_job_launch
      debug_print "Launched workflow #{@name} -> job #{rjid}"
    end
  end
  
  def set_running
    @status = :running
    if Xgw::Globals.host_settings.verbose_job_state
      debug_print "Job #{@rjid} for workflow #{@name} is now running"
    end
  end
  
  def success
    @status = :success
    if Xgw::Globals.host_settings.verbose_job_state
      debug_print "Job #{@rjid} for workflow #{@name} is finished"
    end
  end
  
  def failure(exception)
    @status = :failure
    @exception = exception
    if Xgw::Globals.host_settings.verbose_job_state
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
    if Xgw::Globals.host_settings.verbose_job_wait
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
