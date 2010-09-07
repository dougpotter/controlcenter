=begin skip to avoid requiring ruote installation in production
FrameworkParticipant

class WorkflowNotFound < StandardError
end

class WorkflowDictionary
  def initialize
    @workflows = {}
  end
  
  def define_workflow(name, &block)
    definition = Ruote.process_definition(:name => name) do
      participant 'Framework:record_job_launch'
      sequence :on_error => 'Framework:record_job_failure' do
        instance_eval(&block)
        participant 'Framework:record_job_success'
      end
    end
    @workflows[name] = definition
  end
  
  def get(name)
    @workflows[name] or raise WorkflowNotFound, "No workflow named #{name}"
  end
  
  def invoke_participant(cls, meth)
    part = ParticipantBuilder.build_participant(cls, meth)
    participant part.new
  end
  
  # Note: keys must be strings
  def validate_arguments(required_keys)
    participant :argument_validator, :required_keys => required_keys
  end
end
=end
