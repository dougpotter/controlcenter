# == Schema Information
# Schema version: 20100816164408
#
# Table name: creative_sizes
#
#  id          :integer(4)      not null, primary key
#  height      :float
#  width       :float
#  common_name :string(255)
#

class CreativeSize < ActiveRecord::Base
  has_many :creatives
  # should there be a validation to make sure there's no duplicate sizes - e.g. validates_unique_comination :height :width
end
