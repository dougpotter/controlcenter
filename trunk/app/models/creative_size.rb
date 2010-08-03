# == Schema Information
# Schema version: 20100803143344
#
# Table name: creative_sizes
#
#  id     :integer(4)      not null, primary key
#  height :float
#  width  :float
#

class CreativeSize < ActiveRecord::Base
  has_many :creatives
  # should there be a validation to make sure there's no duplicate sizes - e.g. validates_unique_comination :height :width
end
