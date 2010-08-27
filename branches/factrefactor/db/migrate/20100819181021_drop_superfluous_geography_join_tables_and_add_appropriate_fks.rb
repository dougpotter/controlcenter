class DropSuperfluousGeographyJoinTablesAndAddAppropriateFks < ActiveRecord::Migration
  def self.up
    remove_foreign_key :cities_regions, :cities
    remove_foreign_key :cities_regions, :regions
    drop_table :cities_regions
    remove_foreign_key :countries_regions, :countries
    remove_foreign_key :countries_regions, :regions
    drop_table :countries_regions

    # people's dbs are probably already seeded with geography data
    # which means they'll need to drop that data and re-seed in order
    # to add the new fk. Or, I guess they could re-seed with proper 
    # datat then add the fk constraint??
    add_column :regions, :country_id, :integer, :null => false
    add_foreign_key :regions, :countries
    add_column :cities, :region_id, :integer, :null => false
    add_foreign_key :cities, :regions
  end

  def self.down
    create_table :cities_regions do |t|
      t.integer :city_id, :null => false
      t.integer :region_id, :null => false
    end
    add_foreign_key :cities_regions, :cities
    add_foreign_key :cities_regions, :regions

    create_table :countries_regions do |t|
      t.integer :country_id, :null => false
      t.integer :region_id, :null => false
    end
    add_foreign_key :countries_regions, :countries
    add_foreign_key :countries_regions, :regions

    remove_foreign_key :regions, :countries
    remove_column :regions, :country_id
    remove_foreign_key :cities, :regions
    remove_column :cities, :region_id
  end
end
