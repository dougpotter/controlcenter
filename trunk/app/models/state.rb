# == Schema Information
# Schema version: 20100813163534
#
# Table name: states
#
#  id           :integer(4)      not null, primary key
#  abbreviation :string(255)     not null
#

class State < ActiveRecord::Base
end
