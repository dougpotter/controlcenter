class RenameUniqueViewThroughCountsToUniqueViewThroughConversionCounts < ActiveRecord::Migration
  def self.up
    rename_table :unique_view_through_counts, :unique_view_through_conversion_counts
  end

  def self.down
    rename_table :unique_view_through_conversion_counts, :unique_view_through_counts
  end
end
