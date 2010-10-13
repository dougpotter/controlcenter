class Ecpm < ActiveRecord::Base
  acts_as_unique_fact

  belongs_to :campaign
  belongs_to :media_purchase_method
  belongs_to :audience
  belongs_to :creative

  validates_presence_of :start_time, :end_time, :duration_in_minutes, :ecpm
  validates_as_increasing :start_time, :end_time
  validates_numericality_of :campaign_id, :media_purchase_method_id, :audience_id, :creative_id, :duration_in_minutes, :ecpm, :allow_nil => true
end
