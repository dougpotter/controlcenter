require 'spec_helper'

describe AppnexusSyncWorkflow do
  describe :s3_url_to_location do
    before do
      # there are no real use cases where workflow would be instantiated
      # without specifying any parameters, thus parameters are required
      @workflow = AppnexusSyncWorkflow.new({})
    end
    
    it 'should convert url to location' do
      url = 's3n://bucket/path/to/file'
      # private method
      location = @workflow.__send__(:s3_url_to_location, url)
      location.should == 'bucket:path/to/file'
    end
  end
  
  describe :choose_most_recent_ending_subdir do
    before do
      # there are no real use cases where workflow would be instantiated
      # without specifying any parameters, thus parameters are required
      @workflow = AppnexusSyncWorkflow.new({})
    end
    
    # A duplicate of the test on workflows for earlier problem detection
    it 'should choose the lookup table with the most recent end date when that table does not begin on the most recent start date' do
      subdirs = %w(
        20100501-20100531
        20100520-20100527
      )
      
      subdir = @workflow.__send__(:choose_most_recent_ending_subdir, subdirs)
      subdir.should == '20100501-20100531'
    end
    
    it 'should fail when no subdirs have date ranges' do
      subdirs = %w(
        20100501
        2010052020100527
        hello
      )
      
      lambda do
        subdir = @workflow.__send__(:choose_most_recent_ending_subdir, subdirs)
      end.should raise_exception(AppnexusSyncWorkflow::InvalidLookupPrefix)
    end
    
    # This is not part of a specification, merely documenting implementation's
    # behavior
    it 'should ignore subdirs that are not valid date ranges provided there is at least one valid subdir' do
      subdirs = %w(
        foobar
        20100520-20100527
      )
      
      subdir = @workflow.__send__(:choose_most_recent_ending_subdir, subdirs)
      subdir.should == '20100520-20100527'
    end
  end
  
  describe :build_emr_parameters do
    def sensible_default_parameters
      {
        :s3_xguid_list_prefix => 'test:input/path',
        :output_prefix => 'test:output/path',
        :lookup_prefix => 'test:lookup/path',
      }
    end
    
    before do
      # there are no real use cases where workflow would be instantiated
      # without specifying any parameters, thus parameters are required
      @workflow = AppnexusSyncWorkflow.new({})
    end
    
    it 'should choose the lookup table with the most recent end date when that table does not begin on the most recent start date' do
      subdirs = %w(
        20100501-20100531
        20100520-20100527
      )
      
      @workflow.expects(:find_subdirs).with('test', 'lookup/path').returns(subdirs)
      emr_parameters = @workflow.__send__(:build_emr_parameters, sensible_default_parameters)
      
      # should use the lookup table ending on the last available date
      emr_parameters[:lookup_url].should =~ /20100501-20100531/
      emr_parameters[:lookup_url].should_not =~ /20100520-20100527/
    end
  end
  
  describe :determine_appnexus_filename do
    before do
      # there are no real use cases where workflow would be instantiated
      # without specifying any parameters, thus parameters are required
      @workflow = AppnexusSyncWorkflow.new({})
    end
    
    it 'should comply with seq-[xgraph appnexus id]-[10-chars] format' do
      filename = @workflow.__send__(:determine_appnexus_filename, sensible_parameters)
      filename.should =~ /\Aseg-1337-\w{10}\Z/
    end
    
    def sensible_parameters
      {
        :appnexus_member_id => 1337,
      }
    end
  end
  
  describe :launch_create_list do
    def sensible_default_parameters
      {
        # need emr_command since we use it to build command line to invoke.
        # we stub run method, allowing the built command line to have nil
        # arguments
        :emr_command => ['doit'],
        :s3_xguid_list_prefix => 'test:input/path',
        :output_prefix => 'test:output/path',
        :lookup_prefix => 'test:lookup/path',
      }
    end
    
    def sensible_lookup_subdirs
      %w(
        20100501-20100531
        20100520-20100527
      )
    end
    
    it 'should return chosen lookup location' do
      params = HashWithIndifferentAccess.new(sensible_default_parameters)
      # here we do not supply lookup date range
      params[:lookup_start_date].should be_nil
      params[:lookup_end_date].should be_nil
      
      @workflow = AppnexusSyncWorkflow.new(params)
      @workflow.expects(:find_subdirs).with('test', 'lookup/path').returns(sensible_lookup_subdirs)
      @workflow.expects(:run).returns('Created job flow j-42')
      output = @workflow.launch_create_list
      output[:lookup_location].should_not be_nil
    end
    
    it 'should use specified lookup location when given endpoints' do
      params = HashWithIndifferentAccess.new(sensible_default_parameters)
      # here we do supply lookup date range, and endpoints must be
      # different from dates we use elsewhere
      params[:lookup_start_date] = '20100201'
      params[:lookup_end_date] = '20100203'
      
      @workflow = AppnexusSyncWorkflow.new(params)
      @workflow.stubs(:find_subdirs).raises(Exception, "find_subdirs should not be called when lookup endpoints were given")
      @workflow.expects(:run).returns('Created job flow j-42')
      output = @workflow.launch_create_list
      output[:lookup_location].should == 'test:lookup/path/20100201-20100203/'
    end
  end
end
