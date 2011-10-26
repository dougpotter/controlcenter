class AddPrimaryKeysToFactTables < ActiveRecord::Migration
  def self.up
    # Note that ID columns will appear as the last column in the table, in UIs.
    # A conscious choice was made to not use the new :first => true
    # functionality described in 
    #   http://apidock.com/rails/ActiveRecord/Migration#
    #   919-Positioning-the-column-MySQL-only
    # because of database portability issues.
    add_column :click_counts, :id, :primary_key
    add_column :impression_counts, :id, :primary_key
    add_column :remote_placements, :id, :primary_key
  end

  def self.down
    remove_column :remote_placements, :id
    remove_column :impression_counts, :id
    remove_column :click_counts, :id
  end
end
