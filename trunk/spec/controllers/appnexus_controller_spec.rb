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
    mock_workflow
    
    lambda do
      post 'create', :appnexus_sync_parameters => valid_appnexus_sync_parameter_attributes
      response.should redirect_to(appnexus_sync_index_path)
    end.should change(AppnexusSyncJob, :count).by(1)
  end
  
  it 'should persist passed parameters in job parameters' do
    mock_workflow
    
    # be safe with what type of keys is allowed
    attrs = HashWithIndifferentAccess.new(valid_appnexus_sync_parameter_attributes)
    
    # apparently we have some restrictive validation on instance type
    attrs[:instance_type] = 'fake1.giveninspec'
    
    lambda do
      post 'create', :appnexus_sync_parameters => attrs
      response.should redirect_to(appnexus_sync_index_path)
    end.should change(AppnexusSyncJob, :count).by(1)
    
    job = AppnexusSyncJob.first(:order => 'created_at desc')
    job.should_not be_nil
    # be safe again
    actual_attrs = HashWithIndifferentAccess.new(job.parameters)
    actual_attrs[:instance_type].should == 'fake1.giveninspec'
  end
  
  def mock_workflow
    # mock workflow to test the controller only
    workflow_mock = mock('mock workflow')
    # these expectations are important to keep
    workflow_mock.expects(:launch_create_list).returns({})
    AppnexusSyncWorkflow.expects(:new).returns(workflow_mock)
  end
end
