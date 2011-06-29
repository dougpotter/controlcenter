class UpgradeCampaignsCreativesToFullModel < ActiveRecord::Migration
  def self.up
    add_column :campaigns_creatives, :id, :primary_key
    rename_table :campaigns_creatives, :campaign_creatives
  end

  def self.down
    rename_table :campaign_creatives, :campaigns_creatives
    remove_column :campaigns_creatives, :id
  end
end
