class DataProviderFile < ActiveRecord::Base
  belongs_to :data_provider_channel
  
  validates_presence_of :url
  validates_uniqueness_of :url, :scope => :data_provider_channel_id
end
