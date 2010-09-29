# 6 hours are known to not be enough for hourly updated channels
DataProviderChannel.seed_many(:name, [
  {
    :name => "search-hashed-int",
    :update_frequency => DataProviderChannel::UPDATES_HOURLY,
    :lookback_from_hour => 8,
    :lookback_to_hour => 2,
    :data_provider => DataProvider.find_by_name('Clearspring'),
  },
  {
    :name => "search-hashed-us",
    :update_frequency => DataProviderChannel::UPDATES_HOURLY,
    :lookback_from_hour => 8,
    :lookback_to_hour => 2,
    :data_provider => DataProvider.find_by_name('Clearspring'),
  },
  {
    :name => "share-int",
    :update_frequency => DataProviderChannel::UPDATES_DAILY,
    :lookback_from_hour => 36,
    :lookback_to_hour => 2,
    :data_provider => DataProvider.find_by_name('Clearspring'),
  },
  {
    :name => "share-us",
    :update_frequency => DataProviderChannel::UPDATES_DAILY,
    :lookback_from_hour => 36,
    :lookback_to_hour => 2,
    :data_provider => DataProvider.find_by_name('Clearspring'),
  },
  {
    :name => "view-int",
    :update_frequency => DataProviderChannel::UPDATES_HOURLY,
    :lookback_from_hour => 8,
    :lookback_to_hour => 2,
    :data_provider => DataProvider.find_by_name('Clearspring'),
  },
  {
    :name => "view-us",
    :update_frequency => DataProviderChannel::UPDATES_HOURLY,
    :lookback_from_hour => 8,
    :lookback_to_hour => 2,
    :data_provider => DataProvider.find_by_name('Clearspring'),
  },
])
