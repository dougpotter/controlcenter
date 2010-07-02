class WaitingParticipant < ParticipantBase
  consume(:wait_for_jobs, :input => %w(jids), :sync => true) do
    job_registry = RuoteGlobals.job_registry
    me = job_registry.job_for_rjid!(params.rjid)
    params.input[:jids].each do |rjid|
      job = job_registry.job_for_rjid!(rjid)
      job.wait
      
      unless job.errors.empty?
        job.errors.each do |error|
          # note: O(n) search on each iteration
          unless me.errors.include?(error)
            me.errors << error
          end
        end
      end
      
      if job.status == :failure || job.status == :cascaded_failure
        me.cascaded_failure(job.exception, job.errors)
      end
    end
    
    if me.status == :cascaded_failure
      raise "Failing due to cascade"
    end
  end
end
