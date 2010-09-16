class ConversionCount < ActiveRecord::Base
  acts_as_fact

  belongs_to :campaign

  validates_presence_of :campaign_id, :start_time, :end_time, :duration_in_minutes, :conversion_count
  validates_numericality_of :conversion_count
  validates_as_increasing :start_time, :end_time
  validate :enforce_unique_index

  def enforce_unique_index
    if ConversionCount.exists?(self.attributes)
      errors.add_to_base('There already exists a ConversionCount with the same dimension combination')
    end
  end
end
