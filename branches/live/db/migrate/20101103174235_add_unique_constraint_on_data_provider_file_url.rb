class AddUniqueConstraintOnDataProviderFileUrl < ActiveRecord::Migration
  def self.up
    add_index :data_provider_files, [:data_provider_channel_id, :url], :unique => true
  end

  def self.down
    remove_index :data_provider_files, [:data_provider_channel_id, :url]
  end
end
