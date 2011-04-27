# == Schema Information
# Schema version: 20101220202022
#
# Table name: data_providers
#
#  id   :integer(4)      not null, primary key
#  name :string(255)     not null
#

class DataProvider < ActiveRecord::Base
  has_many :data_provider_channels
  
  validates_presence_of :name
  validates_uniqueness_of :name
end
