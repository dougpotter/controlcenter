class CampaignInventoryConfig < ActiveRecord::Base
  belongs_to :ad_inventory_source
  belongs_to :campaign

  has_many :creative_inventory_configs, :dependent => :delete_all
  has_many :creatives, :through => :creative_inventory_configs

  validates_uniqueness_of :campaign_id, 
    { 
      :scope => :ad_inventory_source_id, 
      :message => "must reference unique AIS-campaign combo" 
    }
end
