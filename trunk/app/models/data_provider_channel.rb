# == Schema Information
# Schema version: 20100816164408
#
# Table name: data_provider_channels
#
#  id               :integer(4)      not null, primary key
#  data_provider_id :integer(4)      not null
#  name             :string(255)     not null
#

class DataProviderChannel < ActiveRecord::Base
  UPDATES_HOURLY = 1
  UPDATES_DAILY = 2
  
  belongs_to :data_provider
  has_many :data_provider_files
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :data_provider_id
end
