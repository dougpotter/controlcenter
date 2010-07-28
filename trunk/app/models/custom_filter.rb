class CustomFilter < ActiveRecord::Base
  has_and_belongs_to_many :line_items
end
