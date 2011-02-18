# == Schema Information
# Schema version: 20101220202022
#
# Table name: line_items
#
#  id             :integer(4)      not null, primary key
#  line_item_code :string(255)     not null
#  name           :string(255)     not null
#  start_time     :datetime
#  end_time       :datetime
#  partner_id     :integer(4)      not null
#

# Line Item is defined as a component of an insertion order which
# specifies quantity and pricing of advertising to be delivered
class LineItem < ActiveRecord::Base
  has_many :campaigns
  has_and_belongs_to_many :creatives
  belongs_to :partner

  validates_presence_of :partner_id
  validates_uniqueness_of :line_item_code

  def partner_name
    self.partner.name
  end

  acts_as_dimension
end
