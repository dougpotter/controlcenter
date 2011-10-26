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
    mock_workflow do |workflow_mock|
      workflow_mock.expects(:launch_create_list).returns({})
    end
    
    lambda do
      post 'create', :appnexus_sync_parameters => valid_appnexus_sync_parameter_attributes
      response.should redirect_to(appnexus_sync_index_path)
    end.should change(AppnexusSyncJob, :count).by(1)
  end
  
  it 'should persist passed parameters in job parameters' do
    mock_workflow do |workflow_mock|
      workflow_mock.expects(:launch_create_list).returns({})
    end
    
    # be safe with what type of keys is allowed
    attrs = HashWithIndifferentAccess.new(valid_appnexus_sync_parameter_attributes)
    
    # apparently we have some restrictive validation on instance type -
    # the value here can't have any dashes or underscores, for example
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
  
  # End-to-end test for issue #1121 - specifying lookup endpoints in UI
  # should result in the created job using that lookup table
  it 'should use passed lookup date endpoints for determining lookup url' do
    # be safe with what type of keys is allowed
    attrs = HashWithIndifferentAccess.new(valid_appnexus_sync_parameter_attributes)
    # specify date range - take care to use unique values
    attrs[:lookup_start_date] = '20100801'
    attrs[:lookup_end_date] = '20100808'
    
    # this is ugly, but it's the price we pay for end-to-end testing
    workflow_params = AppnexusSyncParameters.new(attrs).attributes
    workflow_mock = AppnexusSyncWorkflow.new(attrs)
    workflow_mock.stubs(:find_subdirs).raises(Exception, "find_subdirs should not be called when lookup endpoints were given")
    workflow_mock.expects(:run).returns('Created job flow j-42')
    AppnexusSyncWorkflow.expects(:new).with(workflow_params).returns(workflow_mock)
    
    lambda do
      post 'create', :appnexus_sync_parameters => attrs
      response.should redirect_to(appnexus_sync_index_path)
    end.should change(AppnexusSyncJob, :count).by(1)
    
    job = AppnexusSyncJob.first(:order => 'created_at desc')
    job.should_not be_nil
    # be safe again
    state = HashWithIndifferentAccess.new(job.state)
    state[:lookup_location].should == 'test-lookup-bucket:/20100801-20100808/'
  end
  
  # End-to-end test without specifying lookup endpoints, for completeness
  it 'should persist chosen lookup url when endpoints are not given' do
    # be safe with what type of keys is allowed
    attrs = HashWithIndifferentAccess.new(valid_appnexus_sync_parameter_attributes)
    attrs[:lookup_start_date].should be_nil
    attrs[:lookup_end_date].should be_nil
    
    test_without_specified_lookup_endpoints(attrs)
  end
  
  # QA testing revealed that empty endpoints are treated as specified
  # endpoints which is very wrong. Thus this test which is identical
  # in outcome to the test for not given endpoints except the endpoints are
  # specified as empty strings.
  it 'should look up lookup urls when endpoints are given as empty strings' do
    # be safe with what type of keys is allowed
    attrs = HashWithIndifferentAccess.new(valid_appnexus_sync_parameter_attributes)
    attrs[:lookup_start_date] = ''
    attrs[:lookup_end_date] = ''
    
    test_without_specified_lookup_endpoints(attrs)
  end
  
  def test_without_specified_lookup_endpoints(attrs)
    lookup_subdirs = %w(
      20100802-20100820
      20100803-20100804
    )
    
    # this is ugly, but it's the price we pay for end-to-end testing
    workflow_params = AppnexusSyncParameters.new(attrs).attributes
    workflow_mock = AppnexusSyncWorkflow.new(workflow_params)
    workflow_mock.expects(:find_subdirs).with('test-lookup-bucket', '').returns(lookup_subdirs)
    workflow_mock.expects(:run).returns('Created job flow j-42')
    AppnexusSyncWorkflow.expects(:new).with(workflow_params).returns(workflow_mock)
    
    lambda do
      post 'create', :appnexus_sync_parameters => attrs
      response.should redirect_to(appnexus_sync_index_path)
    end.should change(AppnexusSyncJob, :count).by(1)
    
    job = AppnexusSyncJob.first(:order => 'created_at desc')
    job.should_not be_nil
    # be safe again
    state = HashWithIndifferentAccess.new(job.state)
    # should be the one with most recent end date
    state[:lookup_location].should == 'test-lookup-bucket:/20100802-20100820/'
  end
  
  def mock_workflow
    # mock workflow to test the controller only
    workflow_mock = mock('mock workflow')
    AppnexusSyncWorkflow.expects(:new).returns(workflow_mock)
    yield workflow_mock
  end
end
