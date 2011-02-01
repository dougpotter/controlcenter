class CampaignInventoryConfig < ActiveRecord::Base
  belongs_to :ad_inventory_source
  belongs_to :campaign

  has_many :creative_inventory_configs
  has_many :creatives, :through => :creative_inventory_configs
end
