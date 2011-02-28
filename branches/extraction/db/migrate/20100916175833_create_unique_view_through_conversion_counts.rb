class CreateUniqueViewThroughConversionCounts < ActiveRecord::Migration
  def self.up
    create_table :unique_view_through_counts do |t|
      t.integer :campaign_id, :null => false
      t.integer :ad_inventory_source_id, :null => false
      t.integer :audience_id, :null => false
      t.integer :creative_id, :null => false
      t.timestamp :start_time, :null => false
      t.timestamp :end_time, :null => false
      t.integer :duration_in_minutes
    end

    add_foreign_key :unique_view_through_counts, :campaigns
    add_foreign_key :unique_view_through_counts, :ad_inventory_sources
    add_foreign_key :unique_view_through_counts, :audiences
    add_foreign_key :unique_view_through_counts, :creatives

  end

  def self.down
    remove_foreign_key :unique_view_through_counts, :campaigns
    remove_foreign_key :unique_view_through_counts, :ad_inventory_sources
    remove_foreign_key :unique_view_through_counts, :audiences
    remove_foreign_key :unique_view_through_counts, :creatives

    drop_table :unique_view_through_counts
  end
end
