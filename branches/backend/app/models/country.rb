# == Schema Information
# Schema version: 20101220202022
#
# Table name: countries
#
#  id           :integer(4)      not null, primary key
#  name         :string(255)     not null
#  country_code :string(255)
#

class Country < ActiveRecord::Base
  validates_presence_of :country_code
end