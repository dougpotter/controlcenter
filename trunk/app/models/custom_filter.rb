# == Schema Information
# Schema version: 20100813163534
#
# Table name: custom_filters
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

# Custom Filter is poorly defined at the moment and isn't in use
class CustomFilter < ActiveRecord::Base
  has_and_belongs_to_many :line_items
end
