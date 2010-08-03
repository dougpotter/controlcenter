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

# An Impression is defined as a person viewing an ad. Impression Count
# is defined as an additive metric which records the number of 
# impressions along the dimensions given in the (compound) key comprised
# of all columns except impression count
class ImpressionCount < ActiveRecord::Base
  validates_presence_of :time_window_id, :campaign_id, :creative_id, :ad_inventory_source_id, :geography_id, :audience_id, :impression_count
  validates_numericality_of :impression_count
end

