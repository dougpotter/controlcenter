require 'spec_helper'

describe Ecpm do
  it "should create a new instance given valid attributes" do
    Factory.create(:ecpa)
  end

  it "should require non null ecpa (db test)" do
    u = Factory.build(:ecpa, :ecpa => nil) 
    lambda {
      u.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end 

  it "should require non null ecpa (validations test)" do
    lambda {
      Factory.create(:ecpa, :ecpa => nil) 
    }.should raise_error(ActiveRecord::RecordInvalid)
  end 

  it "should require ecpa to be a number" do  
    lambda {
      Factory.create(:ecpa, :ecpa => "not a number")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end 

  it "should require a valid foreign key to campaigns" do
    lambda {
      Factory.create(:ecpa, :campaign_id => 0)
    }.should raise_error
  end 

  it "should require a valid foreign key to ad_inventory_sources" do
    lambda {      
      Factory.create(:ecpa, :ad_inventory_source_id => 0)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end 

  it "should require a valid foreign key to audiences" do
    lambda {
      Factory.create(:ecpa, :audience_id => 0)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end 

  it "should require a valid foreign key to creatives" do
    lambda {
      Factory.create(:ecpa, :creative_id => 0)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require a start time that occurs before end time" do
    lambda {
      Factory.create(:ecpa, {:start_time => Time.now + 60, :end_time => Time.now})
    }.should raise_error
  end

  it "should require a unique combination of attribues" do
    u = Factory.create(:ecpa)
    a = u.attributes
    lambda {
      Factory.create(:ecpa, a)
    }.should raise_error
  end
end
