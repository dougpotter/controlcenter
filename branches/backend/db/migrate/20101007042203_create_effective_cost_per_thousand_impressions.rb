class CreateEffectiveCostPerThousandImpressions < ActiveRecord::Migration

  # effective_cost_per_thousand_impressions is abreviated to avoid running into
  # the situation where the auto-generated foreign key identifier (by foreigner)
  # is too long for MySQL - which it is if we use the long table name

  def self.up
    create_table :ecpms do |t|
      t.integer :campaign_id
      t.integer :ad_inventory_source_id
      t.integer :media_purchase_method_id
      t.integer :audience_id
      t.integer :creative_id
      t.timestamp :start_time, :null => false
      t.timestamp :end_time, :null => false
      t.integer :duration_in_minutes, :null => false
      t.float :ecpm, :null => false
    end

    add_foreign_key :ecpms, :campaigns
    add_foreign_key :ecpms, :ad_inventory_sources
    add_foreign_key :ecpms, :media_purchase_methods
    add_foreign_key :ecpms, :audiences
    add_foreign_key :ecpms, :creatives

    add_index :ecpms, [ :campaign_id, :ad_inventory_source_id, :media_purchase_method_id, :audience_id, :creative_id, :start_time, :end_time, :duration_in_minutes ], { :name => "ecpms_required_columns", :unique => true }
  end

  def self.down
    remove_index :ecpms, :ecpms_required_columns

    remove_foreign_key :ecpms, :campaigns
    remove_foreign_key :ecpms, :ad_inventory_sources
    remove_foreign_key :ecpms, :media_purchase_methods
    remove_foreign_key :ecpms, :audiences
    remove_foreign_key :ecpms, :creatives

    drop_table :ecpms
  end
end
