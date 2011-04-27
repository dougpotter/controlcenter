class StandardizeCodeColumns < ActiveRecord::Migration
  def self.up
    # Campaigns
    remove_index "campaigns", :name => "index_campaigns_on_cid"
    remove_column :campaigns, :cid
    
    add_index :campaigns, :campaign_code, :unique => true
    
    # Audiences
    rename_column :audiences, :aid, :audience_code
    change_column :audiences, :audience_code, :string, :null => false
    add_index :audiences, :audience_code, :unique => true
    
    # Ad Inventory Sources
    rename_column :ad_inventory_sources, :ais, :ais_code
    add_index :ad_inventory_sources, :ais_code, :unique => true
    
    # Creatives
    rename_column :creatives, :crid, :creative_code
  end

  def self.down
    # Creatives
    rename_column :creatives, :creative_code, :crid
    
    # Ad Inventory Sources
    remove_index :ad_inventory_sources, :ais_code
    rename_column :ad_inventory_sources, :ais_code, :ais
    
    # Audiences
    remove_index :audiences, :audience_code
    change_column :audiences, :audience_code, :integer, :null => false
    rename_column :audiences, :audience_code, :aid

    # Campaigns
    remove_index "campaigns", "campaign_code"
    
    add_column :campaigns, :cid, :integer
    add_index "campaigns", ["cid"], :name => "index_campaigns_on_cid", :unique => true
  end
end
