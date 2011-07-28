# == Schema Information
# Schema version: 20101220202022
#
# Table name: data_provider_channels
#
#  id                 :integer(4)      not null, primary key
#  data_provider_id   :integer(4)      not null
#  name               :string(255)     not null
#  update_frequency   :integer(4)
#  lookback_from_hour :integer(4)      not null
#  lookback_to_hour   :integer(4)      not null
#

class DataProviderChannel < ActiveRecord::Base
  UPDATES_HOURLY = 1
  UPDATES_DAILY = 2
  
  belongs_to :data_provider
  has_many :data_provider_files
  
  named_scope :hourly, :conditions => ['update_frequency = ?', UPDATES_HOURLY]
  
  def update_interval
    case self.update_frequency
    when UPDATES_HOURLY
      3600
    when UPDATES_DAILY
      86400
    when nil
      nil
    else
      raise ArgumentError, "Update frequency unknown: #{self.update_frequency}"
    end
  end
  
  private
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :data_provider_id
  
  validates_presence_of :lookback_from_hour, :lookback_to_hour
  validate :validate_lookback_hours_order
  
  # Since we're talking about the past we can technically call either
  # endpoint "from" (from 3 hours back to 12 hours back and from 12 hours
  # back to 3 hours back both could be used).
  # Enforce sanity by requiring from time to precede to time, absolutely.
  # This means from is the larger value of the two (12 in the above example)
  # and it corresponds to earlier absolute time (12 hours before present).
  def validate_lookback_hours_order
    # validates_presence_of catches unspecified hours
    if lookback_from_hour && lookback_to_hour
      if lookback_from_hour <= lookback_to_hour
        errors.add_to_base("Lookback from hour must be a larger (or equal) value than lookback to hour, corresponding to earlier (or equal) absolute time")
      end
    end
  end
end
