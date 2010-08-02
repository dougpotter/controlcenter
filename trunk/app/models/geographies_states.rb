# == Schema Information
# Schema version: 20100729211736
#
# Table name: geographies_states
#
#  id           :integer(4)      not null, primary key
#  state_id     :integer(4)
#  geography_id :integer(4)
#

class GeographiesStates < ActiveRecord::Base
end
