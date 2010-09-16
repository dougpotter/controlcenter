class CreateUniqueRemotePlacementCounts < ActiveRecord::Migration
  def self.up
    create_table :unique_remote_placement_counts do |t|
      t.integer :audience_id, :null => false
      t.timestamp :start_time, :null => false
      t.timestamp :end_time, :null => false
      t.integer :duration_in_minutes, :null => false
    end

    add_foreign_key :unique_remote_placement_counts, :audiences
  end

  def self.down
    remove_foreign_key :unique_remote_placement_counts, :audiences

    drop_table :unique_remote_placement_counts
  end
end
