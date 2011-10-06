class AddCampaignTypeToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :campaign_type, :string
  end

  def self.down
    remove_column :campaigns, :campaign_type
  end
end
