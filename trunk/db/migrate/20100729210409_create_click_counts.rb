class CreateClickCounts < ActiveRecord::Migration
  def self.up
    create_table :click_counts do |t|
      t.integer :campaign_id, :null => false
      t.integer :creative_id, :null => false
      t.integer :ad_inventory_source_id, :null => false
      t.integer :geography_id, :null => false
      t.integer :audience_id, :null => false
      t.integer :time_window_id, :null => false

      t.integer :click_count, :null => false
    end
    add_foreign_key :click_counts, :campaigns
    add_foreign_key :click_counts, :creatives
    add_foreign_key :click_counts, :ad_inventory_sources
    add_foreign_key :click_counts, :geographies
    add_foreign_key :click_counts, :audiences
    add_foreign_key :click_counts, :time_windows
  end

  def self.down
    drop_table :click_counts
  end
end
