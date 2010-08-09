class AddBusinessIds < ActiveRecord::Migration
  def self.up
    add_column :partners, :pid, :integer, :null => false
    add_column :partner_beacon_requests, :pid, :integer
    add_column :creatives, :crid, :string, :null => false
    add_column :ad_inventory_sources, :ais, :string, :null => false
    add_column :geographies, :msa, :string, :null => false
  end

  def self.down
    remove_column :partners, :pid
    remove_column :partner_beacon_requests, :pid
    remove_column :creatives, :crid
    remove_column :ad_inventory_sources, :ais
    remove_column :geographies, :msa
  end
end
