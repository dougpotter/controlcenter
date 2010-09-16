class UniqueViewThroughConversionCount < ActiveRecord::Base
  acts_as_fact

  validates_presence_of :campaign_id, :ad_inventory_source_id, :creative_id, :start_time, :end_time, :duration_in_minutes, :unique_view_through_conversion_count
  validates_numericality_of :unique_view_through_conversion_count
  validates_as_increasing :start_time, :end_time
  validate :enforce_unique_index

  def enforce_unique_index
    if UniqueViewThroughConversionCount.exists?(self.attributes)
      errors.add_to_base('There already exists a UniqueViewThroughConversionCount with the same dimension attributes')
    end
  end
end
