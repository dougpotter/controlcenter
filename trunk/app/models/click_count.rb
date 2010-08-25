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
  belongs_to :campaign
  belongs_to :creative
  belongs_to :ad_inventory_srouce
  belongs_to :geography
  belongs_to :audience

  validates_presence_of :campaign_id, :creative_id, :ad_inventory_source_id, :audience_id, :start_time, :end_time, :duration_in_minutes, :click_count
  validates_numericality_of :click_count
  validates_as_increasing :start_time, :end_time
  
  def business_objects
    [ campaign, creative, ad_inventory_source, audience ]
  end

  def business_attributes
    ["start_time", "end_time", "duration_in_minutes", "campaign_code", "creative_code", "ad_inventory_source_code", "geography", "audience_code"]
  end
end
