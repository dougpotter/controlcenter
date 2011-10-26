class AddUniquenessIndexToCampaignInventoryConfigs < ActiveRecord::Migration
  def self.up
    cics = CampaignInventoryConfig.all(
      :order => "ad_inventory_source_id, campaign_id"
    )
    for i in 0...cics.size - 1
      if cics[i].campaign_id == cics[i + 1].campaign_id && 
        cics[i].ad_inventory_source_id == cics[i + 1].ad_inventory_source_id
        cics[i].delete
      end
    end
    add_index :campaign_inventory_configs, 
      [ :campaign_id, :ad_inventory_source_id ], 
      { :name => "ensure_unique_ais_campaign_association", :unique => true }
  end

  def self.down
    remove_index :campaign_inventory_configs, 
      :name => "ensure_unique_ais_campaign_association"
  end
end
