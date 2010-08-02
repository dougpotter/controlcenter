# == Schema Information
# Schema version: 20100729211736
#
# Table name: remote_placements
#
#  id                :integer(4)      not null, primary key
#  campaign_id       :integer(4)
#  geography_id      :integer(4)
#  audience_id       :integer(4)
#  time_window_id    :integer(4)
#  remote_placements :integer(4)
#

class RemotePlacement < ActiveRecord::Base
  validates_presence_of :time_window_id, :campaign_id, :geography_id, :audience_id
  validates_numericality_of :remote_placement_count
end
