class CreativesLineItem < ActiveRecord::Base
  belongs_to :line_item
  belongs_to :creative
end
