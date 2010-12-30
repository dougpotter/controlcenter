# == Schema Information
# Schema version: 20101220202022
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

  def height_width_string
    "#{height.to_i} x #{width.to_i}"
  end
end
