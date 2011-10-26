require 'spec_helper'

describe DataProviderChannel do
  # Basic functionality test: it should be possible to create a data provider
  # channel
  it 'should be possible to create a data provider channel' do
    Factory.create(:detached_data_provider_channel)
  end
end
