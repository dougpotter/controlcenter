# == Schema Information
# Schema version: 20100819181021
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
  validates_uniqueness_of :height, :scope => [ :width ]
end
