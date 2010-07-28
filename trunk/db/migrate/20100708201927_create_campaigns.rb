class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns do |t|
      t.text :description,  :null => false 
      t.text :campaign_code, :null => false
      t.date :start_date
      t.date :end_date
      t.integer :partner_id
      t.integer :cid 
    end
    add_index :campaigns, :cid, :unique => true
  end

  def self.down
    drop_table :campaigns
  end
end
