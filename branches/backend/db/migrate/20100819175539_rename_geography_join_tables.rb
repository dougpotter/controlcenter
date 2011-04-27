class RenameGeographyJoinTables < ActiveRecord::Migration
  def self.up
    rename_table :regions_zips, :region_zips
    rename_table :msas_regions, :msa_regions
  end

  def self.down
    rename_table :region_zips, :regions_zips
    rename_table :msa_regions, :msas_regions
  end
end
