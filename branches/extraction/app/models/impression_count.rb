# == Schema Information
# Schema version: 20101220202022
#
# Table name: impression_counts
#
#  campaign_id              :integer(4)      not null
#  creative_id              :integer(4)      not null
#  ad_inventory_source_id   :integer(4)      not null
#  geography_id             :integer(4)
#  audience_id              :integer(4)      not null
#  impression_count         :integer(4)      not null
#  start_time               :datetime
#  end_time                 :datetime
#  duration_in_minutes      :integer(4)
#  id                       :integer(4)      not null, primary key
#  media_purchase_method_id :integer(4)
#

# An Impression is defined as a person viewing an ad. Impression Count
# is defined as an additive metric which records the number of 
# impressions along the dimensions given in the (compound) key comprised
# of all columns except impression count
class ImpressionCount < ActiveRecord::Base
  acts_as_additive_fact
  # TODO: Implement requires_dimensions and accepts_dimensions
  #requires_dimensions :campaign, :ad_inventory_source, :audience, :creative
  #accepts_dimensions :media_purchase_method
  

  belongs_to :campaign
  belongs_to :creative
  belongs_to :ad_inventory_source
  belongs_to :geography
  belongs_to :audience
  belongs_to :media_purchase_method

  validates_presence_of :start_time, :end_time, :duration_in_minutes, :campaign_id, :creative_id, :ad_inventory_source_id, :audience_id, :impression_count
  validates_numericality_of :impression_count
  validates_as_increasing :start_time, :end_time
  validate :enforce_unique_index

  def enforce_unique_index
    if ImpressionCount.exists?(self.attributes)
      errors.add_to_base('There already exists an ImpressionCount with the same dimension combination')
    end
  end

end

