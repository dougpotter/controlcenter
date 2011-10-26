require 'spec_helper'

describe Ecpm do
  it "should create a new instance given valid attributes" do
    Factory.create(:ecpm)
  end

  it "should require non null ecpm (db test)" do
    u = Factory.build(:ecpm, :ecpm => nil) 
    lambda {
      u.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end 

  it "should require non null ecpm (validations test)" do
    lambda {
      Factory.create(:ecpm, :ecpm => nil) 
    }.should raise_error(ActiveRecord::RecordInvalid)
  end 

  it "should require ecpm to be a number" do  
    lambda {
      Factory.create(:ecpm, :ecpm => "not a number")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end 

  it "should require a valid foreign key to campaigns" do
    lambda {
      Factory.create(:ecpm, :campaign_id => 0)
    }.should raise_error
  end 

  it "should require a valid foreign key to ad_inventory_sources" do
    lambda {      Factory.create(:ecpm, :ad_inventory_source_id => 0)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end 

  it "should require a valid foreign key to audiences" do
    lambda {
      Factory.create(:ecpm, :audience_id => 0)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end 

  it "should require a valid foreign key to creatives" do
    lambda {
      Factory.create(:ecpm, :creative_id => 0)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require a start time that occurs before end time" do
    lambda {
      Factory.create(:ecpm, {:start_time => Time.now + 60, :end_time => Time.now})
    }.should raise_error
  end

  it "should require a unique combination of attribues" do
    u = Factory.create(:ecpm)
    a = u.attributes
    lambda {
      Factory.create(:ecpm, a)
    }.should raise_error
  end
end
