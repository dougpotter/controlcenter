class AddLookbackFromAndToHoursToDataProviderChannels < ActiveRecord::Migration
  def self.up
    # this is an ugly hack. fix it with a plugin later
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      add_column :data_provider_channels, :lookback_from_hour, :integer, :null => true
      add_column :data_provider_channels, :lookback_to_hour, :integer, :null => true
      execute 'update data_provider_channels set lookback_from_hour=6, lookback_to_hour=2'
      execute 'alter table data_provider_channels alter lookback_from_hour set not null'
      execute 'alter table data_provider_channels alter lookback_to_hour set not null'
    else
      # mysql cannot just add/remove not null constraint; it insists on being
      # told what the column type is in all column modifications, thus a
      # simple set_column_not_null operation becomes not too simple after
      # accounting for things like collations.
      # fortunately, mysql's casual attitude toward the data it manages allows
      # us to add a not null column with null values without any issues.
      add_column :data_provider_channels, :lookback_from_hour, :integer, :null => false
      add_column :data_provider_channels, :lookback_to_hour, :integer, :null => false
      execute 'update data_provider_channels set lookback_from_hour=6, lookback_to_hour=2'
    end
  end

  def self.down
    remove_column :data_provider_channels, :lookback_from_hour
    remove_column :data_provider_channels, :lookback_to_hour
  end
end
