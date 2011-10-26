# == Schema Information
# Schema version: 20101220202022
#
# Table name: unique_click_counts
#
#  id                       :integer(4)      not null, primary key
#  partner_id               :integer(4)
#  campaign_id              :integer(4)
#  media_purchase_method_id :integer(4)
#  audience_id              :integer(4)
#  creative_id              :integer(4)
#  start_time               :datetime        not null
#  end_time                 :datetime        not null
#  duration_in_minutes      :integer(4)      not null
#  unique_click_count       :integer(4)      not null
#

class UniqueClickCount < ActiveRecord::Base
  acts_as_unique_fact

  belongs_to :partner
  belongs_to :campaign
  belongs_to :media_purchase_method
  belongs_to :audience
  belongs_to :creative

  validates_presence_of :start_time, :end_time, :duration_in_minutes, :unique_click_count
  validates_as_increasing :start_time, :end_time
  validates_numericality_of :partner_id, :campaign_id, :media_purchase_method_id, :audience_id, :creative_id, :duration_in_minutes, :unique_click_count, {:allow_nil => true}
  validate :enforce_unique_index

  def enforce_unique_index
    if UniqueClickCount.exists?(self.attributes)
      errors.add_to_base('There already exists a UniqueClickCount with the same attributes')
    end
  end
end
