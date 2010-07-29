class CreateDataProvidersChannelsFiles < ActiveRecord::Migration
  def self.up
    create_table :data_providers do |t|
      t.string :name, :null => false
    end
    
    create_table :data_provider_channels do |t|
      t.integer :data_provider_id, :null => false
      t.string :name, :null => false
    end
    
    add_foreign_key :data_provider_channels, :data_providers
    
    create_table :data_provider_files do |t|
      t.integer :data_provider_channel_id, :null => false
      t.string :url, :null => false
      t.integer :status, :null => false
    end
    
    add_foreign_key :data_provider_files, :data_provider_channels
  end

  def self.down
    drop_table :data_provider_files
    drop_table :data_provider_channels
    drop_table :data_providers
  end
end
