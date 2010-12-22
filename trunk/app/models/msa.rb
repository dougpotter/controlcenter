# == Schema Information
# Schema version: 20101220202022
#
# Table name: msas
#
#  id       :integer(4)      not null, primary key
#  msa_code :string(255)     not null
#  name     :string(255)
#

class Msa < ActiveRecord::Base
  has_and_belongs_to_many :regions
  validates_presence_of :msa_code
end
