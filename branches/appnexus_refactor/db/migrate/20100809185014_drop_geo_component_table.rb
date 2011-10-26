class DropGeoComponentTable < ActiveRecord::Migration
  def self.up
    drop_table :geo_components
  end

  def self.down
    create_table :geo_components do |t|
      t.integer :id, :null => false
      t.string :description, :null => false
      t.integer :state_id, :null => false
      t.integer :geography_id, :null => false
    end
    change_column :geo_components, :id, :integer
    add_foreign_key :geo_components, :states
    add_foreign_key :geo_components, :geographies
  end
end
