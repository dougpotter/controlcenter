class AddUniqueKeyToFactTables < ActiveRecord::Migration
  def self.up
    add_index :click_counts, [:campaign_id, :creative_id, :ad_inventory_source_id, :audience_id, :start_time, :end_time, :duration_in_minutes], {:name => "click_counts_required_columns", :unique => true}
    add_index :impression_counts, [:campaign_id, :creative_id, :ad_inventory_source_id, :audience_id, :start_time, :end_time, :duration_in_minutes], {:name => "impression_counts_required_columns", :unique => true}
  end

  def self.down
    # migrating down two schemas are possible: with colliding and unique
    # column names.
    # postgres aborts transaction on error and mysql does not support
    # transactional ddl, run postgres commands first, and if they fail do
    # mysql commands.
    begin
      remove_index :click_counts, :name => "click_counts_required_columns"
      remove_index :impression_counts, :name => "impression_counts_required_columns"
    rescue
      remove_index :click_counts, :name => "required_columns"
      remove_index :impression_counts, :name => "required_columns"
    end
  end
end
