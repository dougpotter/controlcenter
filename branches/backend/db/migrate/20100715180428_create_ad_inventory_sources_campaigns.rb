class CreateAdInventorySourcesCampaigns < ActiveRecord::Migration
  def self.up
    create_table :ad_inventory_sources_campaigns, {:id => false } do |t|
      t.integer :campaign_id, :null => false
      t.integer :ad_inventory_source_id, :null => false
    end
  end

  def self.down
    drop_table :ad_inventory_sources_campaigns
  end
end
