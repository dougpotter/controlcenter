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
end
