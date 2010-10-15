Factory.define :detached_data_provider_channel, :class => 'DataProviderChannel' do |r|
  r.name "Test channel #{rand}"
  r.lookback_from_hour 1
  r.lookback_to_hour 0
  r.association :data_provider
end
