# == Schema Information
# Schema version: 20100729211736
#
# Table name: partners
#
#  id   :integer(4)      not null, primary key
#  name :string(255)
#

class Partner < ActiveRecord::Base
  has_many :partner_beacon_requests
  has_many :campaigns

end
