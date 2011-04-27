# == Schema Information
# Schema version: 20101220202022
#
# Table name: geographies
#
#  id         :integer(4)      not null, primary key
#  country_id :integer(4)      not null
#  msa_id     :integer(4)      not null
#  zip_id     :integer(4)      not null
#  region_id  :integer(4)      not null
#

# Geography is defined as an MSA as defined by the U.S. Census bureau.
# http://www.census.gov/population/www/metroareas/lists/2008/List1.txt
class Geography < ActiveRecord::Base
  belongs_to :country
  belongs_to :msa
  belongs_to :zip
  belongs_to :region

  has_many :click_counts
  has_many :impression_counts
  has_many :remote_placements

  # might want to add a validation which requires at least one attribute
  # to be present

  def get_handle 
    ""
  end

  def self.handle_to_id(geography_code)
    ""
  end

  def self.id_to_handle(id)
    ""
  end
end
