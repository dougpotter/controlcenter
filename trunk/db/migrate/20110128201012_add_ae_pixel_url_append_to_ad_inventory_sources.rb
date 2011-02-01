class AddAePixelUrlAppendToAdInventorySources < ActiveRecord::Migration
  def self.up
    add_column :ad_inventory_sources, :ae_pixel_url_append, :string
  end

  def self.down
    remove_column :ad_inventory_sources, :ae_pixel_url_append
  end
end
