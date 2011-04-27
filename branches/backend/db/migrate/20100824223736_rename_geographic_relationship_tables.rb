class RenameGeographicRelationshipTables < ActiveRecord::Migration
  def self.up
    rename_table :region_zips, :regions_zips
    rename_table :msa_regions, :msas_regions
  end

  def self.down
    rename_table :msas_regions, :msa_regions
    rename_table :regions_zips, :region_zips    
  end
end
