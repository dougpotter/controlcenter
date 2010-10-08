class StandardWorkflowRunner < WorkflowRunner
  # Constructor is common to standard workflows.
  def initialize(name, workflow_class)
    @name = name
    @workflow_class = workflow_class
  end
end
