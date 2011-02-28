class DropCampaignFkFromCreatives < ActiveRecord::Migration
  def self.up
    remove_foreign_key :creatives, :campaigns
    remove_column :creatives, :campaign_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
