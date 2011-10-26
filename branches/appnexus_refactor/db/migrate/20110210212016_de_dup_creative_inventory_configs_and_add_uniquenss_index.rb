class DeDupCreativeInventoryConfigsAndAddUniquenssIndex < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE creative_inventory_configs_temp(creative_id INT, campaign_inventory_config_id INT)"
    execute "INSERT INTO creative_inventory_configs_temp SELECT DISTINCT * FROM creative_inventory_configs"
    execute "DELETE FROM creative_inventory_configs"
    execute "INSERT INTO creative_inventory_configs SELECT * FROM creative_inventory_configs_temp"
    execute "DROP TABLE creative_inventory_configs_temp"
    add_index :creative_inventory_configs,
      [ :creative_id, :campaign_inventory_config_id ],
      { :name => "ensure_unique_creative_ais_campaign_association", :unique => true }
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
