# == Schema Information
# Schema version: 20100803143344
#
# Table name: click_counts
#
#  campaign_id            :integer(4)      not null
#  creative_id            :integer(4)      not null
#  ad_inventory_source_id :integer(4)      not null
#  geography_id           :integer(4)      not null
#  audience_id            :integer(4)      not null
#  time_window_id         :integer(4)      not null
#  click_count            :integer(4)      not null
#

# Click Count is defined as an additive metric which records the clicks
# along the dimensions given in the (compound) primary key comprised of
# all columns except click counts
class ClickCount < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :creative
  belongs_to :ad_inventory_srouce
  belongs_to :geography
  belongs_to :audience
  belongs_to :time_window

  validates_presence_of :campaign_id, :creative_id, :ad_inventory_source_id, :geography_id, :audience_id, :time_window_id, :click_count
  validates_numericality_of :click_count
end
