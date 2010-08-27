# == Schema Information
# Schema version: 20100824223747
#
# Table name: zips
#
#  id       :integer(4)      not null, primary key
#  zip_code :string(255)     not null
#

class Zip < ActiveRecord::Base
  has_and_belongs_to_many :regions
  validates_presence_of :zip_code
end
