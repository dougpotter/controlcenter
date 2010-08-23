# == Schema Information
# Schema version: 20100819181021
#
# Table name: regions
#
#  id           :integer(4)      not null, primary key
#  abbreviation :string(255)     not null
#  country_id   :integer(4)      not null
#

class Region < ActiveRecord::Base
  belongs_to :country
  has_and_belongs_to_many :zips
  has_many :cities
  has_and_belongs_to_many :msas
end
