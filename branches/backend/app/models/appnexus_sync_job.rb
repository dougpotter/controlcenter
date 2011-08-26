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
      self.state[:emr_log_uri] = result[:emr_log_uri]
      self.state[:appnexus_list_location] = result[:appnexus_list_location]
      self.state[:lookup_location] = result[:lookup_location]
      save!
    when PROCESSING
      unless self.state[:input_line_count] && self.state[:input_byte_count]
        workflow = AppnexusSyncWorkflow.new(self.parameters)
        workflow.lock(self.id) do
          reload
          input_state = workflow.obtain_input_size(self.parameters['s3_xguid_list_prefix'])
          self.state[:input_line_count] = input_state[:line_count]
          self.state[:input_byte_count] = input_state[:byte_count]
          save!
        end
      end
      
      # we better have the jobflow id
      if job_id = self.state[:emr_jobflow_id]
        begin
          workflow = AppnexusSyncWorkflow.new(self.parameters)
          workflow.lock(self.id) do
            reload
            result = workflow.check_create_list(job_id)
            case result[:success]
            when true
              upload_state = workflow.upload_list(self.state[:appnexus_list_location])
              self.status = COMPLETED
              self.completed_at = Time.now.utc
              [:filename, :line_count, :byte_count].each do |key|
                self.state["output_#{key}".to_sym] = upload_state[key]
              end
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
  
  def emr_log_uri
    if (log_uri = self.state[:emr_log_uri]) &&
      (job_flow_id = self.state[:emr_jobflow_id])
    then
      File.join(log_uri, job_flow_id)
    else
      nil
    end
  end
end
