require 'spec_helper'

describe AppnexusSyncJob do
  it 'should be possible to instantiate one' do
    lambda do
      AppnexusSyncJob.new
    end.should_not raise_error
  end
end
