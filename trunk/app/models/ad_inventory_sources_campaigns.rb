class CampaignsAdInventorySources < ActiveRecord::Base
  validates_presence_of :ad_inventory_source_id
  validates_presence_of :campaign_id
end
