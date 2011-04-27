require 'spec_helper'

describe Ecpc do
  it "should create a new instance given valid attributes" do
    Factory.create(:ecpc)
  end

  it "should require non null ecpc (db test)" do
    u = Factory.build(:ecpc, :ecpc => nil) 
    lambda {
      u.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end 

  it "should require non null ecpc (validations test)" do
    lambda {
      Factory.create(:ecpc, :ecpc => nil) 
    }.should raise_error(ActiveRecord::RecordInvalid)
  end 

  it "should require ecpc to be a number" do  
    lambda {
      Factory.create(:ecpc, :ecpc => "not a number")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end 

  it "should require a valid foreign key to campaigns" do
    lambda {
      Factory.create(:ecpc, :campaign_id => 0)
    }.should raise_error
  end 

  it "should require a valid foreign key to ad_inventory_sources" do
    lambda {      
      Factory.create(:ecpc, :ad_inventory_source_id => 0)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end 

  it "should require a valid foreign key to audiences" do
    lambda {
      Factory.create(:ecpc, :audience_id => 0)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end 

  it "should require a valid foreign key to creatives" do
    lambda {
      Factory.create(:ecpc, :creative_id => 0)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require a start time that occurs before end time" do
    lambda {
      Factory.create(:ecpc, {:start_time => Time.now + 60, :end_time => Time.now})
    }.should raise_error
  end

  it "should require a unique combination of attribues" do
    u = Factory.create(:ecpc)
    a = u.attributes
    lambda {
      Factory.create(:ecpc, a)
    }.should raise_error
  end
end
