require 'spec_helper'

describe AppnexusSyncParameters do
  describe 'Validations' do
    def valid_parameters
      parameters = AppnexusSyncParameters.new.tap do |p|
        p.s3_xguid_list_prefix = 'xg-dev-test:/path/to/files'
        p.appnexus_segment_id = 'TEST'
        p.instance_type = 'm1.small'
        p.instance_count = 2
      end
    end
    
    it "should successfully validate the valid test parameters" do
      parameters = valid_parameters
      parameters.valid?.should be_true
    end
    
    it "should disallow urls as s3 prefixes" do
      parameters = valid_parameters
      parameters.s3_xguid_list_prefix = 'http://xg-dev-test/path/to/files'
      parameters.valid?.should be_false
      
      parameters.s3_xguid_list_prefix = 'http://xg-dev-test.amazonaws.com/path/to/files'
      parameters.valid?.should be_false
    end
    
    it "should require s3 xguid list prefix" do
      parameters = valid_parameters
      parameters.s3_xguid_list_prefix = ''
      parameters.valid?.should be_false
      
      parameters.s3_xguid_list_prefix = nil
      parameters.valid?.should be_false
    end
    
    it 'should require instance type and count' do
      parameters = valid_parameters
      parameters.instance_type = ''
      parameters.valid?.should be_false
      
      parameters.instance_type = nil
      parameters.valid?.should be_false
      
      parameters.instance_count = ''
      parameters.valid?.should be_false
      
      parameters.instance_count = nil
      parameters.valid?.should be_false
    end
  end
  
  describe "Defaults" do
    it "should take instance type from configuration" do
      parameters = AppnexusSyncParameters.new
      # special value in test appnexus.yml configuration
      parameters.instance_type.should == 'fake1.small'
    end
  end
end
