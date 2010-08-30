# == Schema Information
# Schema version: 20100819181021
#
# Table name: impression_counts
#
#  campaign_id            :integer(4)      not null
#  creative_id            :integer(4)      not null
#  ad_inventory_source_id :integer(4)      not null
#  geography_id           :integer(4)
#  audience_id            :integer(4)      not null
#  impression_count       :integer(4)      not null
#  start_time             :datetime
#  end_time               :datetime
#  duration_in_minutes    :integer(4)
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
    impression_count = Factory.create(:impression_count)
    lambda {
      ImpressionCount.create!(impression_count.attributes)
    }.should raise_error(ActiveRecord::ActiveRecordError)
  end
end
