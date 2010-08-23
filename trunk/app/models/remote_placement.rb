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

# Remote Placement is defined as the act of including a targeted
# (internally) user/human to a Remote Audience. Examples of a Remote
# Placement include 1. sending a list of user/humans to AppNexus and
# 2. the arrival - and pixel dropping, specifically - that occurs when 
# a user/human who is a member of an internal Audience arrives at a
# data-provider-affiliated property for the first time after being added
# to that internal Audience. This model wraps a fact
# table which records Remote Placmenets along the dimensions included
# in the (compound) key comprised of all the columns except 
# remote_placement_count
class RemotePlacement < ActiveRecord::Base
  validates_presence_of :time_window_id, :campaign_id, :geography_id, :audience_id
  validates_numericality_of :remote_placement_count
end
