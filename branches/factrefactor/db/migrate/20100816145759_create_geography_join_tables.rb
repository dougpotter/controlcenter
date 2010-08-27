class CreateGeographyJoinTables < ActiveRecord::Migration
  def self.up
    create_table :regions_zips, {:id => false} do |t|
      t.integer :region_id, :null => false
      t.integer :zip_id, :null => false
    end
    create_table :cities_regions, {:id => false} do |t|
      t.integer :city_id, :null => false
      t.integer :region_id, :null => false
    end
    create_table :msas_regions, {:id => false} do |t|
      t.integer :msa_id, :null => false
      t.integer :region_id, :null => false
    end
    create_table :countries_regions, {:id => false} do |t|
      t.integer :country_id, :null => false
      t.integer :region_id, :null => false
    end
    add_foreign_key :regions_zips, :regions
    add_foreign_key :regions_zips, :zips
    add_foreign_key :cities_regions, :cities
    add_foreign_key :cities_regions, :regions
    add_foreign_key :msas_regions, :msas
    add_foreign_key :msas_regions, :regions
    add_foreign_key :countries_regions, :countries
    add_foreign_key :countries_regions, :regions
  end

  def self.down
    remove_foreign_key :regions_zips, :regions
    remove_foreign_key :regions_zips, :zips
    remove_foreign_key :cities_regions, :cities
    remove_foreign_key :cities_regions, :regions
    remove_foreign_key :msas_regions, :msas
    remove_foreign_key :msas_regions, :regions
    remove_foreign_key :countries_regions, :countries
    remove_foreign_key :countries_regions, :regions
    drop_table :regions_zips
    drop_table :cities_regions
    drop_table :msas_regions
    drop_table :countries_regions
  end
end
