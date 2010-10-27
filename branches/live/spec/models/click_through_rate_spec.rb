require 'spec_helper'

describe ClickThroughRate do
  it "should create a new instance given valid attributes" do
    Factory.create(:click_through_rate)
  end 

  it "should require non null click through rate (db test)" do
    u = Factory.build(:click_through_rate, :click_through_rate => nil) 
    lambda {
      u.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end 

  it "should require non null click through rate (validations test)" do
    lambda {
      Factory.create(:click_through_rate, :click_through_rate => nil) 
    }.should raise_error(ActiveRecord::RecordInvalid)
  end 

  it "should require click_through_rate to be a number" do  
    lambda {
      Factory.create(:click_through_rate, :click_through_rate => "not a number")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end 

  it "should require a valid foreign key to campaigns" do
    lambda {
      Factory.create(:click_through_rate, :campaign_id => 0)
    }.should raise_error
  end 

  it "should require a valid foreign key to ad_inventory_sources" do
    lambda {
      Factory.create(:click_through_rate, :ad_inventory_source_id => 0)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end 

  it "should require a valid foreign key to audiences" do
    lambda {
      Factory.create(:click_through_rate, :audience_id => 0)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require a valid foreign key to creatives" do
    lambda {
      Factory.create(:click_through_rate, :creative_id => 0)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require a start time that occurs before end time" do
    lambda {
      Factory.create(:click_through_rate, {:start_time => Time.now + 60, :end_time => Time.now})
    }.should raise_error
  end

  it "should require a unique combination of attribues" do
    u = Factory.create(:click_through_rate)
    a = u.attributes
    lambda {
      Factory.create(:click_through_rate, a)
    }.should raise_error
  end

end
