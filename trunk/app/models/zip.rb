# == Schema Information
# Schema version: 20100816164408
#
# Table name: zips
#
#  id  :integer(4)      not null, primary key
#  zip :string(255)     not null
#

class Zip < ActiveRecord::Base
  has_and_belongs_to_many :regions
  validates_presence_of :zip
end
