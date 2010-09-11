class CreateImpressionCounts < ActiveRecord::Migration
  def self.up
    create_table :impression_counts do |t|
      t.integer :time_window_id, :null => false
      t.integer :campaign_id, :null => false
      t.integer :creative_id, :null => false
      t.integer :ad_inventory_source_id, :null => false
      t.integer :geography_id, :null => false
      t.integer :audience_id, :null => false

      t.integer :impression_count, :null => false
    end
    add_foreign_key :impression_counts, :time_windows
    add_foreign_key :impression_counts, :campaigns
    add_foreign_key :impression_counts, :creatives
    add_foreign_key :impression_counts, :ad_inventory_sources
    add_foreign_key :impression_counts, :geographies
    add_foreign_key :impression_counts, :audiences
  end

  def self.down
    drop_table :impression_counts
  end
end
