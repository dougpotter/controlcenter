# == Schema Information
# Schema version: 20100819181021
#
# Table name: remote_placements
#
#  campaign_id            :integer(4)      not null
#  geography_id           :integer(4)
#  audience_id            :integer(4)      not null
#  remote_placement_count :integer(4)      not null
#  start_time             :datetime
#  end_time               :datetime
#  duration_in_minutes    :integer(4)
#

require 'spec_helper'

describe RemotePlacement do

  it "should create a new instance given valid attributes" do
    Factory.create(:remote_placement)
  end

  it "should require valid foreign key for time windows" do
    lambda {
      Factory.create(:remote_placement, :time_window_id => 0)
    }.should raise_error
  end 

  it "should require valid foreign key for campaigns" do
    lambda {
      Factory.create(:remote_placement, :campaign_id => 0)
    }.should raise_error
  end 

  it "should require valid foreign key for geographies" do
    lambda {
      Factory.create(:remote_placement, :geography_id => 0)
    }.should raise_error
  end 

  it "should require valid foreign key for audiences" do
    lambda {
      Factory.create(:remote_placement, :audience_id => 0)
    }.should raise_error
  end

  it "should require a numerical remote placement count" do
    lambda {
      Factory.create(:remote_placement, :remote_placement_count => "not a number")
    }.should raise_error
  end
end
