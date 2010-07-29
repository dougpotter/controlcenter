class DataProviderChannel < ActiveRecord::Base
  belongs_to :data_provider
  has_many :data_provider_files
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :data_provider_id
end
