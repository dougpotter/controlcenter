class CreateAdInventorySources < ActiveRecord::Migration
  def self.up
    create_table :ad_inventory_sources do |t|
      t.text :name
    end
  end

  def self.down
    drop_table :ad_inventory_sources
  end
end
