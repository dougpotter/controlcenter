# == Schema Information
# Schema version: 20101220202022
#
# Table name: unique_view_through_conversion_counts
#
#  id                                   :integer(4)      not null, primary key
#  campaign_id                          :integer(4)
#  ad_inventory_source_id               :integer(4)
#  audience_id                          :integer(4)
#  creative_id                          :integer(4)
#  start_time                           :datetime        not null
#  end_time                             :datetime        not null
#  duration_in_minutes                  :integer(4)
#  unique_view_through_conversion_count :integer(4)      not null
#

class UniqueViewThroughConversionCount < ActiveRecord::Base
  acts_as_unique_fact

  validates_presence_of :start_time, :end_time, :duration_in_minutes, :unique_view_through_conversion_count
  validates_numericality_of :unique_view_through_conversion_count
  validates_as_increasing :start_time, :end_time
  validate :enforce_unique_index

  def enforce_unique_index
    if UniqueViewThroughConversionCount.exists?(self.attributes)
      errors.add_to_base('There already exists a UniqueViewThroughConversionCount with the same dimension attributes')
    end
  end
end
