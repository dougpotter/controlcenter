# == Schema Information
# Schema version: 20101220202022
#
# Table name: media_costs
#
#  id                       :integer(4)      not null, primary key
#  partner_id               :integer(4)      not null
#  campaign_id              :integer(4)      not null
#  media_purchase_method_id :integer(4)      not null
#  audience_id              :integer(4)      not null
#  creative_id              :integer(4)      not null
#  start_time               :datetime        not null
#  end_time                 :datetime        not null
#  duration_in_minutes      :integer(4)      not null
#  media_cost               :float           not null
#

class MediaCost < ActiveRecord::Base
  acts_as_additive_fact

  belongs_to :partner
  belongs_to :campaign
  belongs_to :media_purchase_method
  belongs_to :audience
  belongs_to :creative
  
  validates_presence_of :partner_id, :campaign_id, :media_purchase_method_id, :audience_id, :creative_id, :start_time, :end_time, :duration_in_minutes, :media_cost
  validates_as_increasing :start_time, :end_time
  validates_numericality_of :partner_id, :campaign_id, :media_purchase_method_id, :audience_id, :creative_id, :duration_in_minutes, :media_cost, {:allow_nil => true}

  validate :enforce_unique_index

  def enforce_unique_index
    if MediaCost.exists?(self.attributes)
      errors.add_to_base('There already exists a MediaCost fact with the same attributes')
    end
  end
end
