# == Schema Information
# Schema version: 20100824223747
#
# Table name: countries
#
#  id           :integer(4)      not null, primary key
#  name         :string(255)     not null
#  country_code :string(255)
#

class Country < ActiveRecord::Base
end
