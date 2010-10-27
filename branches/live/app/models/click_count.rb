require_dependency 'custom_validations'

# == Schema Information
# Schema version: 20100819181021
#
# Table name: click_counts
#
#  campaign_id            :integer(4)      not null
#  creative_id            :integer(4)      not null
#  ad_inventory_source_id :integer(4)      not null
#  geography_id           :integer(4)
#  audience_id            :integer(4)      not null
#  click_count            :integer(4)      not null
#  start_time             :datetime
#  end_time               :datetime
#  duration_in_minutes    :integer(4)
#

# Click Count is defined as an additive metric which records the clicks
# along the dimensions given in the (compound) primary key comprised of
# all columns except click counts
class ClickCount < ActiveRecord::Base
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

  validates_presence_of :campaign_id, :creative_id, :ad_inventory_source_id, :audience_id, :start_time, :end_time, :duration_in_minutes, :click_count
  validates_numericality_of :click_count
  validates_as_increasing :start_time, :end_time
  validate :enforce_unique_index

  def enforce_unique_index
    if ClickCount.exists?(self.attributes)
      errors.add_to_base('There is already a click count with the same dimension combination')
    end
  end

end
