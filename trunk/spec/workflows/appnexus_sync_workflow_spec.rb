require 'spec_helper'

describe AppnexusSyncWorkflow do
  describe :s3_url_to_location do
    before do
      # there are no real use cases where workflow would be instantiated
      # without specifying any parameters, thus parameters are required
      @workflow = AppnexusSyncWorkflow.new({})
    end
    
    it 'should convert url to location' do
      url = 's3n://bucket/path/to/file'
      # private method
      location = @workflow.__send__(:s3_url_to_location, url)
      location.should == 'bucket:path/to/file'
    end
  end
end
