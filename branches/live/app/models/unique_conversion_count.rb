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
