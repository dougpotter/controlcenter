# == Schema Information
# Schema version: 20100729211736
#
# Table name: click_counts
#
#  id                     :integer(4)      not null, primary key
#  campaign_id            :integer(4)
#  creative_id            :integer(4)
#  ad_inventory_source_id :integer(4)
#  geography_id           :integer(4)
#  audience_id            :integer(4)
#  time_window_id         :integer(4)
#

class ClickCount < ActiveRecord::Base
  validates_presence_of :campaign_id, :creative_id, :ad_inventory_source_id, :geography_id, :audience_id, :time_window_id, :click_count
  validates_numericality_of :click_count
end
