# == Schema Information
# Schema version: 20100729211736
#
# Table name: models
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#

class Model < ActiveRecord::Base
  has_many :audiences
end
