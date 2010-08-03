# == Schema Information
# Schema version: 20100803143344
#
# Table name: geographies
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#

# Geography is defined as an MSA as defined by the U.S. Census bureau.
# http://www.census.gov/population/www/metroareas/lists/2008/List1.txt
class Geography < ActiveRecord::Base
  has_and_belongs_to_many :campaigns
end
