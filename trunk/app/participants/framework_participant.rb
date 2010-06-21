class FrameworkParticipant < ParticipantBase
  consume(:record_job_launch, :sync => true) do
    job = RuoteGlobals.job_registry.job_for_rjid!(params.rjid)
    job.set_running
  end
  
  consume(:record_job_success, :sync => true) do
    job = RuoteGlobals.job_registry.job_for_rjid!(params.rjid)
    job.success
  end
  
  consume(:record_job_failure, :sync => true) do
    job = RuoteGlobals.job_registry.job_for_rjid!(params.rjid)
    fei, time, error_class_name, error_message, error_backtrace = params.workitem.fields['__error__']
    if error_class_name.blank?
      raise ArgumentError, "Error class name is blank - version of ruote used is too old?"
    end
    exception = error_class_name.constantize.new(error_message)
    exception.set_backtrace(error_backtrace)
    job.failure(exception)
  end
end
