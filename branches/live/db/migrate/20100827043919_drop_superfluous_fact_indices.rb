class DropSuperfluousFactIndices < ActiveRecord::Migration
  def self.up
    remove_index :click_counts, :name => "required_columns"
    remove_index :impression_counts, :name => "required_columns"
  end

  def self.down
    add_index "click_counts", ["campaign_id", "creative_id", "ad_inventory_source_id", "audience_id", "start_time", "end_time", "duration_in_minutes"], :name => "required_columns", :unique => true
    add_index "impression_counts", ["campaign_id", "creative_id", "ad_inventory_source_id", "audience_id", "start_time", "end_time", "duration_in_minutes"], :name => "required_columns", :unique => true
  end
end
