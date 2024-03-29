# == Schema Information
# Schema version: 20101220202022
#
# Table name: jobs
#
#  id           :integer(4)      not null, primary key
#  type         :string(255)     not null
#  name         :string(255)     not null
#  parameters   :text            not null
#  created_at   :datetime        not null
#  status       :integer(4)      not null
#  state        :text            not null
#  completed_at :datetime
#

class AppnexusSyncJob < Job
  def run(options={})
    case self.status
    when CREATED
      self.status = PROCESSING
      save!
      workflow = AppnexusSyncWorkflow.new(self.parameters.update(options))
      result = workflow.launch_create_list
      self.state[:emr_jobflow_id] = result[:emr_jobflow_id]
      self.state[:appnexus_list_location] = result[:appnexus_list_location]
      self.state[:lookup_location] = result[:lookup_location]
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
              msg = "Failing job because check_create_list returned false"
              append_diagnostics(msg)
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
          append_diagnostics(format_exception(e))
          self.status = FAILED
          self.completed_at = Time.now.utc
          save!
        end
      else
        # the job may not have failed, but we should not hide potential
        # failure and lacking jobflow id is a failure somewhere
        msg = "Failing job due to missing state[:emr_jobflow_id]"
        append_diagnostics(msg)
        self.status = FAILED
        self.completed_at = Time.now.utc
        save!
      end
    end
  end
end
