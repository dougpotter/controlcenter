class DataProviderFile < ActiveRecord::Base
  belongs_to :data_provider_channel
  
  def initialize(options)
    default_options = {:status => 0}
    super(default_options.update(options))
  end
  
  validates_presence_of :url
  validates_uniqueness_of :url, :scope => :data_provider_channel_id
end
