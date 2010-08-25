# == Schema Information
# Schema version: 20100824223747
#
# Table name: regions
#
#  id          :integer(4)      not null, primary key
#  region_code :string(255)     not null
#  country_id  :integer(4)      not null
#

class Region < ActiveRecord::Base
  belongs_to :country
  has_and_belongs_to_many :zips
  has_many :cities
  has_and_belongs_to_many :msas
  
  validates_presence_of :region_code
end
