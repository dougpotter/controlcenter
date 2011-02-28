class AddCountColumnsToFactTables < ActiveRecord::Migration
  def self.up
    add_column :conversion_counts, :conversion_count, :integer, :null => false
    add_column :unique_conversion_counts, :unique_conversion_count, :integer, :null => false
    add_column :unique_remote_placement_counts, :unique_remote_placement_count, :integer, :null => false
    add_column :unique_view_through_conversion_counts, :unique_view_through_conversion_count, :integer, :null => false
  end

  def self.down
    remove_column :conversion_counts, :conversion_count
    remove_column :unique_conversion_counts, :unique_conversion_count
    remove_column :unique_remote_placement_counts, :unique_remote_placement_count
    remove_column :unique_view_through_conversion_counts, :unique_view_through_conversion_count
  end
end
