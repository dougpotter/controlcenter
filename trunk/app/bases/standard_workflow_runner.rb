class StandardWorkflowRunner < Workflow::Runner
  # Constructor is common to standard workflows.
  def initialize(workflow_class)
    # XXX maybe recheck/reconsider name transformation logic later
    @name = workflow_class.data_provider_name.underscore.gsub(' ', '-').gsub('_', '-')
    @workflow_class = workflow_class
  end
end
