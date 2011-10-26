class CreateClickThroughRates < ActiveRecord::Migration
  def self.up
    create_table :click_through_rates do |t|
      t.integer :campaign_id
      t.integer :ad_inventory_source_id
      t.integer :media_purchase_method_id
      t.integer :audience_id
      t.integer :creative_id
      t.timestamp :start_time, :null => false
      t.timestamp :end_time, :null => false
      t.integer :duration_in_minutes, :null => false
      t.float :click_through_rate, :null => false
    end

    add_foreign_key :click_through_rates, :campaigns
    add_foreign_key :click_through_rates, :ad_inventory_sources
    add_foreign_key :click_through_rates, :media_purchase_methods
    add_foreign_key :click_through_rates, :audiences
    add_foreign_key :click_through_rates, :creatives

    add_index :click_through_rates, [ :campaign_id, :ad_inventory_source_id, :media_purchase_method_id, :audience_id, :creative_id, :start_time, :end_time, :duration_in_minutes ], { :name => "click_through_rates_required_columns", :unique => true }
  end

  def self.down
    remove_index :click_through_rates, :click_through_rates_required_columns

    remove_foreign_key :click_through_rates, :campaigns
    remove_foreign_key :click_through_rates, :ad_inventory_sources
    remove_foreign_key :click_through_rates, :media_purchase_methods
    remove_foreign_key :click_through_rates, :audiences
    remove_foreign_key :click_through_rates, :creatives

    drop_table :click_through_rates
  end
end
