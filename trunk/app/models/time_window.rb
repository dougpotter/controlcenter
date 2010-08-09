# == Schema Information
# Schema version: 20100803143344
#
# Table name: time_windows
#
#  id           :integer(4)      not null, primary key
#  window_begin :datetime
#  window_end   :datetime
#

require 'custom_validations'
class TimeWindow < ActiveRecord::Base
  has_many :campaigns

  has_many :click_counts
  has_many :insertion_orders

  validates_as_increasing :window_begin, :window_end, {:allow_nil => true}
  validates_as_datetime :window_begin, :window_end
end
