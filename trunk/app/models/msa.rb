# == Schema Information
# Schema version: 20100816164408
#
# Table name: msas
#
#  id       :integer(4)      not null, primary key
#  msa_code :string(255)     not null
#

class Msa < ActiveRecord::Base
  has_and_belongs_to_many :regions
  validates_presence_of :zip
end
