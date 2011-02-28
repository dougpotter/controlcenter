class CreateEffectiveCostPerClicks < ActiveRecord::Migration

  # the abreviated table name is to preserve the convention necessitated (and
  # described) in CreateEffectiveCostPerThousandImpressions

  def self.up
    create_table :ecpcs do |t| 
      t.integer :campaign_id
      t.integer :ad_inventory_source_id
      t.integer :media_purchase_method_id
      t.integer :audience_id
      t.integer :creative_id
      t.timestamp :start_time, :null => false
      t.timestamp :end_time, :null => false
      t.integer :duration_in_minutes, :null => false
      t.float :ecpc, :null => false
    end 

    add_foreign_key :ecpcs, :campaigns
    add_foreign_key :ecpcs, :ad_inventory_sources
    add_foreign_key :ecpcs, :media_purchase_methods
    add_foreign_key :ecpcs, :audiences
    add_foreign_key :ecpcs, :creatives

    add_index :ecpcs, [:campaign_id, :ad_inventory_source_id, :media_purchase_method_id, :audience_id, :creative_id], { :name => "ecpcs_required_columns", :unique => true }
  end 

  def self.down
    remove_index :ecpcs, :name => "ecpcs_require_columns"
    remove_foreign_key :ecpcs, :campaigns
    remove_foreign_key :ecpcs, :ad_inventory_sources
    remove_foreign_key :ecpcs, :media_purchase_methods
    remove_foreign_key :ecpcs, :audiences
    remove_foreign_key :ecpcs, :creatives

    drop_table :ecpcs
  end
end
