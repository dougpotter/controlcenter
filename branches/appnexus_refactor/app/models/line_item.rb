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
  has_many :campaigns, :dependent => :destroy
  has_many :creatives_line_items
  has_many :creatives, :through => :creatives_line_items, :dependent => :destroy
  belongs_to :partner

  validates_presence_of :partner_id, :line_item_code, :name
  validates_uniqueness_of :line_item_code
  validates_as_increasing :start_time, :end_time,
    :message => "must follow start time"

  def partner_name
    self.partner.name
  end

  acts_as_dimension


  class << self
    def generate_line_item_code
      CodeGenerator.generate_unique_code(
        self,
        :line_item_code,
        :length => 4,
        :alphabet => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
      )   
    end 
  end
end
