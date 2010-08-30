# == Schema Information
# Schema version: 20100819181021
#
# Table name: click_counts
#
#  campaign_id            :integer(4)      not null
#  creative_id            :integer(4)      not null
#  ad_inventory_source_id :integer(4)      not null
#  geography_id           :integer(4)
#  audience_id            :integer(4)      not null
#  click_count            :integer(4)      not null
#  start_time             :datetime
#  end_time               :datetime
#  duration_in_minutes    :integer(4)
#

require 'spec_helper'

describe ClickCount do

  it "should create a new instance given valid attributes" do
    Factory.create(:click_count)
  end

  it "should require valid foreign key for time windows" do
    lambda {
      Factory.create(:click_count, :time_window_id => 0)
    }.should raise_error
  end 

  it "should require valid foreign key for campaigns" do
    lambda {
      Factory.create(:click_count, :campaign_id => 0)
    }.should raise_error
  end 

  it "should require valid foreign key for creatives" do
    lambda {
      Factory.create(:click_count, :creative_id => 0)
    }.should raise_error
  end 

  it "should require valid foreign key for ad inventory sources" do
    lambda {
      Factory.create(:click_count, :ad_inventory_source_id => 0)
    }.should raise_error
  end 

  it "should require valid foreign key for geographies" do
    lambda {
      Factory.create(:click_count, :geography_id => 0)
    }.should raise_error
  end 

  it "should require valid foreign key for audiences" do
    lambda {
      Factory.create(:click_count, :audience_id => 0)
    }.should raise_error
  end 

  it "should require numerical click count" do
    lambda {
    Factory.create(:click_count, :click_count => "not a number")
    }.should raise_error
  end

  it "should require end_time after start_time" do
    lambda {
      Factory.create(:click_count, {:start_time => Time.now + 60, :end_time => Time.now})
    }.should raise_error
  end

  it "should have unique combination of required attributes" do
    pending
    click_count = Factory.create(:click_count)
    lambda {
      ClickCount.create!(click_count.attributes)
    }.should raise_error(ActiveRecord::ActiveRecordError)
  end
end
