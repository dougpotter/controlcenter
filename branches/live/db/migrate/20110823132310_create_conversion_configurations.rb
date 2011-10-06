class CreateConversionConfigurations < ActiveRecord::Migration
  def self.up
    create_table :conversion_configurations do |t|
      t.string :conversion_configuration_code, :null => false
      t.string :name, :null => false
      t.integer :partner_id, :null => false
      t.integer :audience_source_id, :null => false
    end

    add_foreign_key :conversion_configurations, :partners
    add_foreign_key :conversion_configurations, :audience_sources
  end

  def self.down
    remove_foreign_key :conversion_configurations, :partners
    remove_foreign_key :conversion_configurations, :audience_sources
    drop_table :conversion_configurations
  end
end
