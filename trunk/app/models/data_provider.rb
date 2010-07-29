class DataProvider < ActiveRecord::Base
  has_many :data_provider_channels
  
  validates_presence_of :name
  validates_uniqueness_of :name
end
