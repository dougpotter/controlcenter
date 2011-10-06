class UpgradeAdInventorySourcesCampaignsToJoinModel < ActiveRecord::Migration
  def self.up
    rename_table :ad_inventory_sources_campaigns, :campaign_inventory_configs
    add_column :campaign_inventory_configs, :id, :integer
    change_column :campaign_inventory_configs, :id, :primary_key
  end

  def self.down
    remove_column :campaign_inventory_configs, :id
    rename_table :campaign_inventory_configs, :ad_inventory_sources_campaigns
  end
end
