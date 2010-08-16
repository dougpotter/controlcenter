class ClearspringVerifyWorkflow < Workflow::Base
  def initialize(params)
    @params = params
    @http_client = create_http_client(@params)
  end
  
  def check_listing
    wf = ClearspringExtractWorkflow.new(@params)
    p wf.discover
  end
  
  def check_consistency
  end
  
  def check_our_existence
  end
  
  def check_their_existence
  end
end
