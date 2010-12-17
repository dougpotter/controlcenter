class AppnexusSyncJob < Job
  def run
    case self.status
    when CREATED
      self.status = PROCESSING
      save!
      
      workflow = AppnexusSyncWorkflow.new(self.parameters)
      result = workflow.launch_create_list
      self.state[:emr_jobflow_id] = result[:emr_jobflow_id]
      self.state[:appnexus_list_location] = result[:appnexus_list_location]
      save!
    when PROCESSING
      # we better have the jobflow id
      if job_id = self.state[:emr_jobflow_id]
        begin
          workflow = AppnexusSyncWorkflow.new(self.parameters)
          workflow.lock(self.id) do
            result = workflow.check_create_list(job_id)
            case result[:success]
            when true
              workflow.upload_list(self.state[:appnexus_list_location])
              self.status = COMPLETED
              self.completed_at = Time.now.utc
              save!
            when false
              self.status = FAILED
              self.completed_at = Time.now.utc
              save!
            else
              # nil, which means the list creation is still running
            end
          end
        rescue Interrupt, SystemExit
          raise
        rescue Exception => e
          if diag = self.state[:diagnostics]
            diag += "\n"
          else
            diag = ''
          end
          diag += "#{e.class}: #{e.message}"
          e.backtrace.each do |line|
            diag += "\n#{line}"
          end
          self.state[:diagnostics] = diag
          self.status = FAILED
          self.completed_at = Time.now.utc
          save!
        end
      else
        # the job may not have failed, but we should not hide potential
        # failure and lacking jobflow id is a failure somewhere
        self.status = FAILED
        self.completed_at = Time.now.utc
        save!
      end
    end
  end
end
