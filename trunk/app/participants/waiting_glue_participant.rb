class WaitingGlueParticipant < ParticipantBase
  consume(:prepare_jobs_to_wait_for, :require_output_value => true, :sync => true) do
    params.input[:jids] = params.output.value
  end
  
  # wait for a single job.
  # launching one job is not necessary but we do it for clarity/consistency
  consume(:prepare_job_to_wait_for, :require_output_value => true, :sync => true) do
    params.input[:jids] = [params.output.value]
  end
end
