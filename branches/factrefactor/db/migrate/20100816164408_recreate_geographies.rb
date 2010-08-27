class RecreateGeographies < ActiveRecord::Migration
  def self.up
    create_table :geographies do |t|
      t.integer :country_id, :null => false
      t.integer :msa_id, :null => false
      t.integer :zip_id, :null => false
      t.integer :region_id, :null => false
    end
    add_foreign_key :geographies, :countries
    add_foreign_key :geographies, :msas
    add_foreign_key :geographies, :zips
    add_foreign_key :geographies, :regions
    add_foreign_key :campaigns_geographies, :geographies
    add_foreign_key :click_counts, :geographies
    add_foreign_key :impression_counts, :geographies
    add_foreign_key :remote_placements, :geographies
  end

  def self.down
    remove_foreign_key :geographies, :countries
    remove_foreign_key :geographies, :msas
    remove_foreign_key :geographies, :zips
    remove_foreign_key :geographies, :regions
    remove_foreign_key :campaigns_geographies, :geographies
    remove_foreign_key :click_counts, :geographies
    remove_foreign_key :impression_counts, :geographies
    remove_foreign_key :remote_placements, :geographies

    drop_table :geographies
  end
end
