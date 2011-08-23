# == Schema Information
# Schema version: 20101220202022
#
# Table name: partners
#
#  id           :integer(4)      not null, primary key
#  name         :string(255)
#  partner_code :integer(4)      not null
#

# Partner is defined as a client on whose behalf we execute Campaigns
class Partner < ActiveRecord::Base
  has_many :partner_beacon_requests
  has_many :line_items
  has_many :action_tags, :dependent => :destroy
  has_many :conversion_configurations

  validates_presence_of :partner_code, :name
  validates_uniqueness_of :partner_code

  accepts_nested_attributes_for :action_tags, :allow_destroy => true
  accepts_nested_attributes_for :conversion_configurations, :allow_destroy => true

  def pid ; partner_code ; end
  
  def partner_code_and_name
    "#{partner_code} #{name}"
  end

  acts_as_dimension
  business_index :partner_code, :aka => "pid"

  acts_as_apn_object :apn_attr_map => {
    :name => "name",
    :code => "partner_code" },
    :non_method_attr_map => {
      :state => "active" },
    :apn_wrapper => "advertiser",
    :urls => {
      :index => "advertiser",
      :new => "advertiser",
      :view => "advertiser?code=##partner_code##",
      :delete_by_apn_ids => "advertiser?id=##apn_id##" }

  def campaigns 
    Campaign.all(
      :joins => { :line_item => :partner},
      :conditions => [ "partners.id = ?", self.id ] )
  end
  
  class << self
    def generate_partner_code
      CodeGenerator.generate_unique_code(
        self,
        :partner_code,
        :length => 5,
        :alphabet => '1234567890',
        :transform => lambda { |code| code.to_i },
        :reject_if => lambda { |code| code.to_s.length != 5 }
      )
    end
  end
end
