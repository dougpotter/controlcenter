class CreateCreativeInventoryConfigs < ActiveRecord::Migration
  def self.up
    # NOTE: if i use the full table name creative_inventory_configurations, the fk
    # identifier with ad_inventory_source_campaigns is too long. so i shortened
    # the table name figuring this was less bad than omitting the fk constraint
    # or changing the table name to something more abstruse.

    create_table :creative_inventory_configs, :id => false do |t|
      t.integer :creative_id, :null => false
      t.integer :campaign_inventory_config_id, :null => false
      t.boolean :configured, :null => false
    end
    add_foreign_key :creative_inventory_configs, :creatives
    add_foreign_key :creative_inventory_configs, :campaign_inventory_configs
  end

  def self.down
    drop_table :creative_inventory_configs
  end
end
