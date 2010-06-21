class WaitingParticipant < ParticipantBase
  consume(:wait_for_jobs, :input => %w(jids), :sync => true) do
    params.input[:jids].each do |jid|
      RuoteGlobals.job_registry.wait_for_rjid(jid)
    end
  end
end
