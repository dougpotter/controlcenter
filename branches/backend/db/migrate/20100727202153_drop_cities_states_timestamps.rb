class DropCitiesStatesTimestamps < ActiveRecord::Migration
  def self.up
    remove_column :geographies_cities, :created_at
    remove_column :geographies_cities, :updated_at
    remove_column :geographies_states, :created_at
    remove_column :geographies_states, :updated_at
  end

  def self.down
    change_table :geographies_cities do |t|
      t.timestamps
    end
    change_table :geographies_states do |t|
      t.timestamps
    end
  end
end
