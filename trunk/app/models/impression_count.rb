# == Schema Information
# Schema version: 20100816164408
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

# An Impression is defined as a person viewing an ad. Impression Count
# is defined as an additive metric which records the number of 
# impressions along the dimensions given in the (compound) key comprised
# of all columns except impression count
class ImpressionCount < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :creative
  belongs_to :ad_inventory_source
  belongs_to :geography
  belongs_to :audience

  validates_presence_of :start_time, :end_time, :duration_in_minutes, :campaign_id, :creative_id, :ad_inventory_source_id, :audience_id, :impression_count
  validates_numericality_of :impression_count
  validates_as_increasing :start_time, :end_time, :allow_nil => false

  def business_attributes
    ["start_time", "end_time", "duration_in_minutes", "campaign_code", "creative_code", "ais_code", "audience_code", "geography"]
  end

end

