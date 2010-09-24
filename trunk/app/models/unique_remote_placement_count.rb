class UniqueRemotePlacementCount < ActiveRecord::Base
  acts_as_unique_fact

  validates_presence_of :start_time, :end_time, :duration_in_minutes, :unique_remote_placement_count
  validates_numericality_of :unique_remote_placement_count
  validates_as_increasing :start_time, :end_time
  validate :enforce_unique_index

  def enforce_unique_index
    if UniqueRemotePlacementCount.exists?(self.attributes)
      errors.add_to_base('There already exists a UniqueRemotePlacementCount with the same dimension attributes')
    end
  end
end
