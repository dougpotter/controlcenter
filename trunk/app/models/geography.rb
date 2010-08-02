# == Schema Information
# Schema version: 20100729211736
#
# Table name: geographies
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#

class Geography < ActiveRecord::Base
  has_and_belongs_to_many :campaigns
end
