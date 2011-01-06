require 'spec_helper'

describe AppnexusSyncParameters do
  describe 'Validations' do
    include AppnexusSyncParameterGenerationHelper
    
    def valid_parameters
      parameters = AppnexusSyncParameters.new.tap do |p|
        valid_appnexus_sync_parameter_attributes.each do |key, value|
          p.send("#{key}=", value)
        end
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
  
  describe 'Empty value treatment' do
    it 'should store empty lookup endpoints as nil when using attribute methods' do
      parameters = AppnexusSyncParameters.new
      parameters.lookup_start_date = ''
      parameters.lookup_start_date.should be_nil
      
      parameters.lookup_end_date = ''
      parameters.lookup_end_date.should be_nil
    end
    
    it 'should store empty lookup endpoints as nil when using bulk assignment' do
      parameters = AppnexusSyncParameters.new
      parameters.attributes = {
        :lookup_start_date => '',
        :lookup_end_date => '',
      }
      parameters.lookup_start_date.should be_nil
      parameters.lookup_end_date.should be_nil
    end
    
    it 'should store empty lookup endpoints as nil when using constructor arguments' do
      parameters = AppnexusSyncParameters.new(
        :lookup_start_date => '',
        :lookup_end_date => ''
      )
      parameters.lookup_start_date.should be_nil
      parameters.lookup_end_date.should be_nil
    end
    
    it 'should return nil lookup endpoints in attributes' do
      parameters = AppnexusSyncParameters.new
      attrs = parameters.attributes
      attrs[:lookup_start_date].should be_nil
      attrs[:lookup_end_date].should be_nil
    end
    
    it 'should return nil lookup endpoints in attributes after assignment' do
      parameters = AppnexusSyncParameters.new
      parameters.lookup_start_date = ''
      parameters.lookup_end_date = ''
      
      attrs = parameters.attributes
      attrs[:lookup_start_date].should be_nil
      attrs[:lookup_end_date].should be_nil
    end
  end
end
