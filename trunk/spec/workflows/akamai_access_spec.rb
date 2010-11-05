require 'spec_helper'

class TestAkamaiWorkflow
  include AkamaiAccess
  
  attr_reader :channel
  
  def initialize
    @channel = Factory.create(:detached_data_provider_channel, :name => 'logs-by-pid/42')
  end
  
  # since we are testing private methods we need to be able to call them
  private_instance_methods.each do |method|
    public method
  end
end

describe AkamaiAccess do
  before do
    @wrapper = TestAkamaiWorkflow.new
  end
  
  it "should use name date for s3 prefix" do
    s3_prefix = @wrapper.build_s3_prefix('/root/akamai/xgraph_f.201010310000-2400.0.log.gz')
    s3_prefix.should == '42/raw/20101031'
  end
  
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
end
