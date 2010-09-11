class RenameMsaToGeography < ActiveRecord::Migration
  def self.up
    rename_table :msas, :geographies
    remove_foreign_key :campaigns_msas, :msa
    remove_foreign_key :campaigns_msas, :campaign
    rename_column :campaigns_msas, :msa_id, :geography_id
    rename_table :campaigns_msas, :campaigns_geographies
    add_foreign_key :campaigns_geographies, :geographies
    add_foreign_key :campaigns_geographies, :campaigns
    
  end

  def self.down
    rename_table :geographies, :msas
    remove_foreign_key :campaigns_geographies, :geographies
    remove_foreign_key :campaigns_geographies, :campaigns
    rename_column :campaigns_geographies, :geography_id, :msa_id
    rename_table :campaigns_geographies, :campaigns_msas  
    add_foreign_key :campaigns_msas, :msas
    add_foreign_key :campaigns_msas, :campaigns
  end
end
