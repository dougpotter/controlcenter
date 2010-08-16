class DropDeprecatedGeographyTables < ActiveRecord::Migration
  def self.up
    remove_foreign_key :click_counts, :geographies
    remove_foreign_key :impression_counts, :geographies
    remove_foreign_key :remote_placements, :geographies
    remove_foreign_key :campaigns_geographies, :geographies
    drop_table :geographies
    drop_table :geographies_cities
    drop_table :geographies_states
  end

  def self.down
    create_table :geographies do |t| 
      t.string :description
      t.string :msa
    end
    add_foreign_key :click_counts, :geographies
    add_foreign_key :impression_counts, :geographies
    add_foreign_key :remote_placements, :geographies
    add_foreign_key :campaigns_geographies, :geographies
    create_table :geographies_cities do |t|
      t.integer :city_id, :null => false
      t.integer :geography_id, :null => false
    end
    create_table :geographies_states do |t|
      t.integer :stat_id, :null => false
      t.integer :geography_id, :null => false
    end
  end
end
