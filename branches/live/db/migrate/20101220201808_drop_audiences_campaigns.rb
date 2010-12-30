class DropAudiencesCampaigns < ActiveRecord::Migration
  def self.up
    remove_foreign_key :audiences_campaigns, :audiences
    remove_foreign_key :audiences_campaigns, :campaigns
    drop_table :audiences_campaigns
  end

  def self.down
    create_table "audiences_campaigns", :id => false, :force => true do |t|
      t.integer "audience_id", :null => false
      t.integer "campaign_id", :null => false
    end
    
    add_foreign_key :audiences_campaigns, :audiences
    add_foreign_key :audiences_campaigns, :campaigns
  end
end
