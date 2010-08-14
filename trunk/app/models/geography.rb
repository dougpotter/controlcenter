# == Schema Information
# Schema version: 20100813163534
#
# Table name: geographies
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  msa         :string(255)     not null
#

# Geography is defined as an MSA as defined by the U.S. Census bureau.
# http://www.census.gov/population/www/metroareas/lists/2008/List1.txt
class Geography < ActiveRecord::Base
  has_and_belongs_to_many :campaigns
  has_many :states
  has_many :cities

  has_many :click_counts
  has_many :impression_counts

  def business_code
    ""
  end

  def self.code_to_pk(geography_code)
    ""
  end
end
