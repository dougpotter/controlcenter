class RemoveIdFromGeoJoinTables < ActiveRecord::Migration
  def self.up
    remove_column :geographies_cities, :id
    remove_column :geographies_states, :id
  end

  def self.down
    add_column :geographies_cities, :id, :primary_key
    add_column :geographies_states, :id, :primary_key
  end
end
