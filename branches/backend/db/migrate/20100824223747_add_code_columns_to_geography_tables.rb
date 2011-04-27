class AddCodeColumnsToGeographyTables < ActiveRecord::Migration
  def self.up
    add_column :countries, :country_code, :string, :length => 2, :null => :false
    add_column :msas, :name, :string
    rename_column :regions, :abbreviation, :region_code
    rename_column :zips, :zip, :zip_code
  end

  def self.down
    rename_column :zips, :zip_code, :zip
    rename_column :regions, :region_code, :abbreviation
    remove_column :msas, :name
    remove_column :countries, :country_code
  end
end
