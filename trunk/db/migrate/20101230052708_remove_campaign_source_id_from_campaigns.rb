class RemoveCampaignSourceIdFromCampaigns < ActiveRecord::Migration
  def self.up
    remove_column :campaigns, :campaign_source_id
  end

  def self.down
    add_column :campaigns, :campaign_source_id, :integer, :null => false
  end
end
