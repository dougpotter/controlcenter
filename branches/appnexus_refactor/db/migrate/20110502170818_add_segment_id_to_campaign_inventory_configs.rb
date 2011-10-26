class AddSegmentIdToCampaignInventoryConfigs < ActiveRecord::Migration
  def self.up
    add_column :campaign_inventory_configs, :segment_id, :string
  end

  def self.down
    remove_column :campaign_inventory_configs, :segment_id
  end
end
