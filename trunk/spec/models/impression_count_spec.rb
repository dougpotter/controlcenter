# == Schema Information
# Schema version: 20100803143344
#
# Table name: impression_counts
#
#  time_window_id         :integer(4)      not null
#  campaign_id            :integer(4)      not null
#  creative_id            :integer(4)      not null
#  ad_inventory_source_id :integer(4)      not null
#  geography_id           :integer(4)      not null
#  audience_id            :integer(4)      not null
#  impression_count       :integer(4)      not null
#

require 'spec_helper'
require 'factory_girl'
describe ImpressionCount do
  it "should create instance of impression count if given valid attrs" do
    Factory.create(:impression_count)
  end

  it "should require valid foreign key for campaigns" do
    lambda {
      Factory.create(:impression_count, :campaign_id => 0)
    }.should raise_error
  end

  it "should require valid foreign key for creatives" do
    lambda {
      Factory.create(:impression_count, :creative_id => 0)
    }.should raise_error
  end

  it "should require valid foreign key for ad inventory sources" do
    lambda {
      Factory.create(:impression_count, :ad_inventory_source_id => 0)
    }.should raise_error
  end

  it "should require valid foreign key for audiences" do
    lambda {
      Factory.create(:impression_count, :audience_id => 0)
    }.should raise_error
  end

  it "should require a numerical impression count" do 
    lambda {
      Factory.create(:impression_count, :impression_count => "not a numba")
    }.should raise_error
  end

  it "should require a start time that occurs before end time" do
    lambda {
      Factory.create(:impression_count, {:start_time => Time.now + 60, :end_time => Time.now})
    }.should raise_error
  end

  it "should require a unique combination of required dimensions" do
    attrs = {:campaign_id => 1, :creative_id => 1, :ad_inventory_source_id => 1, :audience_id => 1, :impression_count => 100, :start_time => Time.now, :end_time => (Time.now + 60), :duration_in_minutes => 1}
    Factory.create(:impression_count, attrs)
    lambda {
      Factory.create(:impression_count, attrs)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end
end
