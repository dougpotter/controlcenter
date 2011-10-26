class RemoveIdFromFactTables < ActiveRecord::Migration
  def self.up
    remove_column :click_counts, :id
    remove_column :impression_counts, :id
    remove_column :remote_placements, :id
  end

  def self.down
    add_column :click_counts, :id, :primary_key
    add_column :impression_counts, :id, :primary_key
    add_column :remote_placements, :id, :primary_key
  end
end
