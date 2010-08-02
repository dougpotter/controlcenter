# == Schema Information
# Schema version: 20100729211736
#
# Table name: geographies_cities
#
#  id           :integer(4)      not null, primary key
#  city_id      :integer(4)
#  geography_id :integer(4)
#

class GeographiesCities < ActiveRecord::Base
end
