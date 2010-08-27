# == Schema Information
# Schema version: 20100819181021
#
# Table name: insertion_orders
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  campaign_id :integer(4)
#

# Insertion Order is a directive from a partner to deliver advertising.
# Line Items on the insertion order specify the terms (quantity and
# price) of delivery
class InsertionOrder < ActiveRecord::Base
  validates_numericality_of :campaign_id
end
