class MakeCampaignsCreativesManyToMany < ActiveRecord::Migration
  def self.up
    create_table :campaigns_creatives, {:id => false} do |t|
      t.integer :campaign_id, :null => false
      t.integer :creative_id, :null => false
    end
    add_foreign_key :campaigns_creatives, :campaigns
    add_foreign_key :campaigns_creatives, :creatives
  end

  def self.down
    remove_foreign_key :campaigns_creatives, :campaigns
    remove_foreign_key :campaigns_creatives, :creatives
    drop_table :campaigns_creatives
  end
end
