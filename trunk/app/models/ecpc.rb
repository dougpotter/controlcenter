# == Schema Information
# Schema version: 20101220202022
#
# Table name: ecpcs
#
#  id                       :integer(4)      not null, primary key
#  campaign_id              :integer(4)
#  ad_inventory_source_id   :integer(4)
#  media_purchase_method_id :integer(4)
#  audience_id              :integer(4)
#  creative_id              :integer(4)
#  start_time               :datetime        not null
#  end_time                 :datetime        not null
#  duration_in_minutes      :integer(4)      not null
#  ecpc                     :float           not null
#

class Ecpc < ActiveRecord::Base
  acts_as_unique_fact

  belongs_to :campaign
  belongs_to :media_purchase_method
  belongs_to :audience
  belongs_to :creative

  validates_presence_of :start_time, :end_time, :duration_in_minutes, :ecpc
  validates_as_increasing :start_time, :end_time
  validates_numericality_of :campaign_id, :media_purchase_method_id, :audience_id, :creative_id, :duration_in_minutes, :ecpc, :allow_nil => true
end
