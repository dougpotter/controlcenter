class CreateRemotePlacements < ActiveRecord::Migration
  def self.up
    create_table :remote_placements do |t|
      t.integer :campaign_id, :null => false
      t.integer :geography_id, :null => false
      t.integer :audience_id, :null => false
      t.integer :time_window_id, :null => false

      t.integer :remote_placement_count, :null => false
    end
    add_foreign_key :remote_placements, :campaigns
    add_foreign_key :remote_placements, :geographies
    add_foreign_key :remote_placements, :audiences
    add_foreign_key :remote_placements, :time_windows
  end

  def self.down
    drop_table :remote_placements
  end
end
