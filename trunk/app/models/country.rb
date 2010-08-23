# == Schema Information
# Schema version: 20100819181021
#
# Table name: countries
#
#  id   :integer(4)      not null, primary key
#  name :string(255)     not null
#

class Country < ActiveRecord::Base
end
