require 'spec_helper'

describe DataProviderChannel do
  # Basic functionality test: it should be possible to create a data provider
  it 'should be possible to create a data provider' do
    Factory.create(:data_provider)
  end
end
