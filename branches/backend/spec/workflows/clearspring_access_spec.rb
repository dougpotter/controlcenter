require 'spec_helper'

module TestClearspringParams
  def params
    {
      :clearspring_pid => 1337,
      :data_source_root => 'https://dex.clearspring.com/data/xgraph/v2',
      :date => '20101030'
    }
  end
  
  def legitimate_channel_name
    'view-us'
  end
  
  def legitimate_data_provider_file_path
    'https://dex.clearspring.com/data/xgraph/v2/view-us/view-us.20101108-1400.1.log.gz'
  end
  
  def correct_s3_dirname_for_path
    '1337/v2/raw-view-us/20101108'
  end
  
  def correct_s3_dirname_for_params
    '1337/v2/raw-view-us/20101030'
  end
end

class TestClearspringWorkflow
  include ClearspringAccess
  include TestClearspringParams
  
  attr_reader :channel
  
  def initialize
    @channel = Factory.create(:detached_data_provider_channel, :name => legitimate_channel_name)
  end
  
  # since we are testing private methods we need to be able to call them
  private_instance_methods.each do |method|
    public method
  end
end

describe ClearspringAccess do
  include TestClearspringParams
  
  before do
    @wrapper = TestClearspringWorkflow.new
  end
  
  describe 'S3 path building' do
    # Test for building s3 dirnames from paths.
    # Date encoded in path should be used.
    it "should use name date for s3 dirname for a path" do
      s3_dirname = @wrapper.build_s3_dirname_for_path(legitimate_data_provider_file_path)
      s3_dirname.should == correct_s3_dirname_for_path
    end
    
    # Test for building s3 dirnames from params.
    # Path in this case is not given and cannot be used by the dirname generating code.
    # Date should be taken from params.
    it "should be able to build correct s3 dirname for params" do
      s3_dirname = @wrapper.build_s3_dirname_for_params
      s3_dirname.should == correct_s3_dirname_for_params
    end
  end
end
