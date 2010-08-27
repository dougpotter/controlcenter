class AddMediaPurchaseMethodToFactUniqueIndices < ActiveRecord::Migration
  def self.up    
    add_index "impression_counts", ["campaign_id", "creative_id", "ad_inventory_source_id", "audience_id", "media_purchase_method_id", "start_time", "end_time", "duration_in_minutes"], :name => "impression_counts_required_columns_20100827", :unique => true
    add_index "click_counts", ["campaign_id", "creative_id", "ad_inventory_source_id", "audience_id", "media_purchase_method_id", "start_time", "end_time", "duration_in_minutes"], :name => "click_counts_required_columns_20100827", :unique => true
    
    remove_index :impression_counts, :name => "impression_counts_required_columns"
    remove_index :click_counts, :name => "click_counts_required_columns"
  end

  def self.down
    add_index "impression_counts", ["campaign_id", "creative_id", "ad_inventory_source_id", "audience_id", "start_time", "end_time", "duration_in_minutes"], :name => "impression_counts_required_columns", :unique => true
    add_index "click_counts", ["campaign_id", "creative_id", "ad_inventory_source_id", "audience_id", "start_time", "end_time", "duration_in_minutes"], :name => "click_counts_required_columns", :unique => true

    remove_index :impression_counts, :name => "impression_counts_required_columns_20100827"
    remove_index :click_counts, :name => "click_counts_required_columns_20100827"
  end
end
