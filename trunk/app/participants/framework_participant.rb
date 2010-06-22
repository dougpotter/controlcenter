class FrameworkParticipant < ParticipantBase
  # Changes job state to running.
  #
  # When jobs are submitted to ruote their state is set to launched.
  # Framework inserts a call to record_job_launch participant as
  # the first step of any workflow. This participant sets job state
  # to running, indicating that ruote began actually executing the job.
  consume(:record_job_launch, :sync => true) do
    job = RuoteGlobals.job_registry.job_for_rjid!(params.rjid)
    job.set_running
  end
  
  # Changes job state to success.
  #
  # Ruote effectively discards job state when jobs finish successfully.
  # Framework inserts a call to record_job_success participant as the
  # last step of every workflow. This participant sets the job state to
  # success, explicitly marking successful jobs. Framework job state is
  # persistent, allowing status querying of any past or current job.
  consume(:record_job_success, :sync => true) do
    job = RuoteGlobals.job_registry.job_for_rjid!(params.rjid)
    job.success
  end
  
  # Changes job state to failure.
  #
  # When jobs fail (meaning an exception was not handled by workflow and
  # propagated up to ruote code) ruote marks the job as errored.
  # These error marks are kept in storage and are not conveniently
  # accessible, nor is their interface officially documented.
  # record_job_failure participant is inserted by framework to handle
  # exceptions propagated from workflows. It sets the job state to
  # failure and handles the exception so that from ruote's point of view
  # the job finishes successfully (which means it does not create error
  # entries).
  #
  # This participant does not handle exceptions in the framework itself
  # (i.e., any code outside of user defined workflows and participants).
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
