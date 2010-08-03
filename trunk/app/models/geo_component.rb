# == Schema Information
# Schema version: 20100803143344
#
# Table name: geo_components
#
#  id           :integer(4)      not null, primary key
#  description  :string(255)     not null
#  state_id     :integer(4)      not null
#  geography_id :integer(4)      not null
#

# Geo Component is defined as a smaller geographic area than Geography.
# Components comprise Geographies.
class GeoComponent < ActiveRecord::Base
end
