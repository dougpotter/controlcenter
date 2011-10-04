require 'spec_helper'

module TestAkamaiParams
  def params
    {:data_source_root => '/root/akamai', :date => '20101030'}
  end
  
  def legitimate_channel_name
    'logs-by-pid/42'
  end
  
  def legitimate_data_provider_file_path
    '/root/akamai/logs-by-pid/42/xgraph_f.201010310000-2400.0.log.gz'
  end
  
  def correct_s3_dirname_for_path
    # the tricky part here is that the label time is 20101101-0000
    '42/raw/20101031'
  end
  
  def correct_s3_dirname_for_params
    '42/raw/20101030'
  end
end

class TestAkamaiWorkflow
  include AkamaiAccess
  include Workflow::S3PathBuilding
  include TestAkamaiParams
  
  attr_reader :channel
  
  def initialize
    @channel = Factory.create(:detached_data_provider_channel, :name => legitimate_channel_name)
  end
  
  # since we are testing private methods we need to be able to call them
  private_instance_methods.each do |method|
    public method
  end
end

describe AkamaiAccess do
  include TestAkamaiParams
  
  before do
    @wrapper = TestAkamaiWorkflow.new
  end
  
  describe 'S3 path building' do
    # Test for building s3 dirnames from paths.
    # Date encoded in path should be used.
    it "should use name date for s3 dirname for a path" do
      s3_dirname = @wrapper.build_s3_dirname_for_path(legitimate_data_provider_file_path)
      s3_dirname.should == correct_s3_dirname_for_path
    end
    
    # Test for building s3 dirnames from params.
    # Path in this case is not given and cannot be used by the dirname generating code.
    # Date should be taken from params.
    it "should be able to build correct s3 dirname for params" do
      s3_dirname = @wrapper.build_s3_dirname_for_params
      s3_dirname.should == correct_s3_dirname_for_params
    end
  end
  
  describe 'Time identification' do
    it "should properly identify time range endpoints for daily updated files" do
      date, start_hour, end_hour = @wrapper.date_and_hours_from_name('xgraph_f.201010310000-2400.0.log.gz')
      date.should == '20101031'
      start_hour.should == 0
      end_hour.should == 24
    end
    
    it "should properly identify time range endpoints for hourly updated files" do
      date, start_hour, end_hour = @wrapper.date_and_hours_from_name('xgraph_f.201010302000-2100.0.log.gz')
      date.should == '20101030'
      start_hour.should == 20
      end_hour.should == 21
    end
    
    it "should properly identify time range endpoints for four-hourly updated files" do
      date, start_hour, end_hour = @wrapper.date_and_hours_from_name('xgraph_f.201010310000-2400.0.log.gz')
      date.should == '20101031'
      start_hour.should == 0
      end_hour.should == 24
    end
    
    it 'should determine name date correctly when log file time range does not end on midnight' do
      date = @wrapper.determine_name_date_from_data_provider_file('xgraph_f.201010302000-2100.0.log.gz')
      date.should == '20101030'
    end
    
    it 'should determine name date correctly when log file time range ends on midnight' do
      date = @wrapper.determine_name_date_from_data_provider_file('xgraph_f.201010302000-2400.0.log.gz')
      date.should == '20101030'
    end
    
    it 'should determine label date and hour correctly when log file time range does not end on midnight' do
      label_date, label_hour = @wrapper.determine_label_date_hour_from_data_provider_file('xgraph_f.201010302000-2100.0.log.gz')
      label_date.should == '20101030'
      label_hour.should == 21
    end
    
    it 'should determine label date and hour correctly when log file time range ends on midnight' do
      label_date, label_hour = @wrapper.determine_label_date_hour_from_data_provider_file('xgraph_f.201010302000-2400.0.log.gz')
      label_date.should == '20101031'
      label_hour.should == 0
    end
  end
end
