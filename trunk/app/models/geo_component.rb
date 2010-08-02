# == Schema Information
# Schema version: 20100729211736
#
# Table name: geo_components
#
#  id           :integer(4)      not null, primary key
#  description  :string(255)     not null
#  state_id     :integer(4)      not null
#  geography_id :integer(4)      not null
#

class GeoComponent < ActiveRecord::Base
end
