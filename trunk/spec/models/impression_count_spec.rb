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

  it "should require valid foreign key for time windows" do
    lambda {
      Factory.create(:impression_count, :time_window_id => 0)
    }.should raise_error
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

  it "should require valid foreign key for geographies" do
    lambda {
      Factory.create(:impression_count, :geography_id => 0)
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
end
