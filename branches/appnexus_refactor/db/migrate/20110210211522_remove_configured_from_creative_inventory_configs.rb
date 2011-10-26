class RemoveConfiguredFromCreativeInventoryConfigs < ActiveRecord::Migration
  def self.up
    remove_column :creative_inventory_configs, :configured
  end

  def self.down
    add_column :creative_inventory_configs, :configured, :boolean, :null => false
  end
end
