require 'spec_helper'

describe AppnexusController do
  include AppnexusSyncParameterGenerationHelper
  
  # Basic functionality test for index action.
  it "should generate index without errors" do
    get 'index'
    response.should be_success
  end
  
  # Requesting the new form should succeed.
  it 'should present new form successfully' do
    get 'new'
    response.should be_success
    response.should render_template('new')
  end
  
  it 'should not accept a sync when no parameters have been specified' do
    post 'create'
    response.should_not be_redirect
    response.should render_template('new')
  end
  
  # Functionality test for creating a new sync:
  # 1. A sync job should be created.
  # 2. User should be redirected back to index.
  # 3. A workflow should be launched
  it 'should create a sync when valid set of parameters is specified' do
    # mock workflow to test the controller only
    workflow_mock = mock('mock workflow')
    workflow_mock.expects(:launch_create_list).returns({})
    AppnexusSyncWorkflow.expects(:new).returns(workflow_mock)
    
    lambda do
      post 'create', :appnexus_sync_parameters => valid_appnexus_sync_parameter_attributes
      response.should redirect_to(appnexus_sync_index_path)
    end.should change(AppnexusSyncJob, :count).by(1)
  end
end
