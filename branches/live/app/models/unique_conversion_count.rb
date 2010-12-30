# == Schema Information
# Schema version: 20101220202022
#
# Table name: unique_conversion_counts
#
#  id                      :integer(4)      not null, primary key
#  campaign_id             :integer(4)
#  start_time              :datetime        not null
#  end_time                :datetime        not null
#  duration_in_minutes     :integer(4)      not null
#  unique_conversion_count :integer(4)      not null
#

class UniqueConversionCount < ActiveRecord::Base
  acts_as_unique_fact

  belongs_to :campaign

  validates_presence_of :start_time, :end_time, :duration_in_minutes, :unique_conversion_count
  validates_numericality_of :unique_conversion_count
  validates_as_increasing :start_time, :end_time
  validate :enforce_unique_index

  def enforce_unique_index
    if UniqueConversionCount.exists?(self.attributes)
      errors.add_to_base('There already exists a UniqueConversionCount with the same dimension combination')
    end
  end
end
