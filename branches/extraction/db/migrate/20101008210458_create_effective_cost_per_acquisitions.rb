class CreateEffectiveCostPerAcquisitions < ActiveRecord::Migration

  # the abreaviated table name is to preserve the convention necessitated (and
  # explained) in CreateEffectiveCostPerThousandImpressions

  def self.up
    create_table :ecpas do |t| 
      t.integer :campaign_id
      t.integer :ad_inventory_source_id
      t.integer :media_purchase_method_id
      t.integer :audience_id
      t.integer :creative_id
      t.timestamp :start_time, :null => false
      t.timestamp :end_time, :null => false
      t.integer :duration_in_minutes, :null => false
      t.float :ecpa, :null => false
    end 

    add_foreign_key :ecpas, :campaigns
    add_foreign_key :ecpas, :ad_inventory_sources
    add_foreign_key :ecpas, :media_purchase_methods
    add_foreign_key :ecpas, :audiences
    add_foreign_key :ecpas, :creatives

    add_index :ecpas, [ :campaign_id, :ad_inventory_source_id, :media_purchase_method_id, :audience_id, :creative_id ], { :name => "ecpas_required_columns", :unique => true }
  end 

  def self.down
    remove_index :ecpas, :ecpas_required_columns

    remove_foreign_key :ecpas, :campaigns
    remove_foreign_key :ecpas, :ad_inventory_sources
    remove_foreign_key :ecpas, :media_purchase_methods
    remove_foreign_key :ecpas, :audiences
    remove_foreign_key :ecpas, :creatives

    drop_table :ecpas
  end
end
