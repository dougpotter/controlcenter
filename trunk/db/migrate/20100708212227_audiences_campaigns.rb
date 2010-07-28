class AudiencesCampaigns < ActiveRecord::Migration
  def self.up
    create_table :audiences_campaigns, { :id => false } do |t|
      t.integer :audience_id, :null => false
      t.integer :campaign_id, :null => false
    end
  end

  def self.down
    drop_table :audiences_campaigns
  end
end
