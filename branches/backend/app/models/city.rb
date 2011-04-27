# == Schema Information
# Schema version: 20101220202022
#
# Table name: cities
#
#  id        :integer(4)      not null, primary key
#  name      :string(255)     not null
#  region_id :integer(4)      not null
#

class City < ActiveRecord::Base
  belongs_to :region
  validates_presence_of :name
end
