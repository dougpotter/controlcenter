class AllowNullDimensionsOnUniqueFactTables < ActiveRecord::Migration
  def self.up
    change_column :unique_remote_placement_counts, :audience_id, :integer, :null => true

    change_column :unique_view_through_conversion_counts, :campaign_id, :integer, :null => true
    change_column :unique_view_through_conversion_counts, :ad_inventory_source_id, :integer, :null => true
    change_column :unique_view_through_conversion_counts, :audience_id, :integer, :null => true
    change_column :unique_view_through_conversion_counts, :creative_id, :integer, :null => true
  end

  def self.down
    change_column :unique_remote_placement_counts, :audience_id, :integer, :null => false

    change_column :unique_view_through_conversion_counts, :campaign_id, :integer, :null => false
    change_column :unique_view_through_conversion_counts, :ad_inventory_source_id, :integer, :null => false
    change_column :unique_view_through_conversion_counts, :audience_id, :integer, :null => false
  end
end
