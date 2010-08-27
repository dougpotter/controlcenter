# == Schema Information
# Schema version: 20100819181021
#
# Table name: models
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#

# Model is defined as an algorithm we use to generate and Internal
# Audience
class Model < ActiveRecord::Base
  has_many :audiences
end
