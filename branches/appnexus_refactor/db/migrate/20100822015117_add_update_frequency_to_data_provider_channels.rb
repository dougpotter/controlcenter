class AddUpdateFrequencyToDataProviderChannels < ActiveRecord::Migration
  def self.up
    add_column :data_provider_channels, :update_frequency, :integer
  end

  def self.down
    remove_column :data_provider_channels, :update_frequency
  end
end
