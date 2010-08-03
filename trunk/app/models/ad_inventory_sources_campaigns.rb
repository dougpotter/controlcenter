# == Schema Information
# Schema version: 20100803143344
#
# Table name: ad_inventory_sources_campaigns
#
#  campaign_id            :integer(4)      not null
#  ad_inventory_source_id :integer(4)      not null
#

class AdInventorySourcesCampaigns < ActiveRecord::Base
  validates_presence_of :ad_inventory_source_id
  validates_presence_of :campaign_id
end
