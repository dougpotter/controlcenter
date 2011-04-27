class AllowGeographyToBeNullOnFactTables < ActiveRecord::Migration
  def self.up
    change_column :click_counts, :geography_id, :integer, :null => true
    change_column :impression_counts, :geography_id, :integer, :null => true
    change_column :remote_placements, :geography_id, :integer, :null => true
  end

  def self.down
    change_column :click_counts, :geography_id, :integer, :null => false
    change_column :impression_counts, :geography_id, :integer, :null => false
    change_column :remote_placements, :geography_id, :integer, :null => false
  end
end
