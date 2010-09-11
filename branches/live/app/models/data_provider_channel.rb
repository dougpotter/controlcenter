# == Schema Information
# Schema version: 20100819181021
#
# Table name: data_provider_channels
#
#  id               :integer(4)      not null, primary key
#  data_provider_id :integer(4)      not null
#  name             :string(255)     not null
#

class DataProviderChannel < ActiveRecord::Base
  UPDATES_HOURLY = 1
  UPDATES_DAILY = 2
  
  belongs_to :data_provider
  has_many :data_provider_files
  
  named_scope :hourly, :conditions => ['update_frequency = ?', UPDATES_HOURLY]
  
  private
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :data_provider_id
  
  validates_presence_of :lookback_from_hours, :lookback_to_hours
  validate :validate_lookback_hours_order
  
  # Since we're talking about the past we can technically call either
  # endpoint "from" (from 3 hours back to 12 hours back and from 12 hours
  # back to 3 hours back both could be used).
  # Enforce sanity by requiring from time to precede to time, absolutely.
  # This means from is the larger value of the two (12 in the above example)
  # and it corresponds to earlier absolute time (12 hours before present).
  def validate_lookback_hours_order
    # validates_presence_of catches unspecified hours
    if lookback_from_hours && lookback_to_hours
      if lookback_from_hours <= lookback_to_hours
        errors.add_to_base("Lookback from hours must be a larger (or equal) value than lookback to hours, corresponding to earlier (or equal) absolute time")
      end
    end
  end
end
