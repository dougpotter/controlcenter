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

  def request_conditions
    results = []
    for audience in Beacon.new.audiences.audiences
      if audience['pid'] == self.partner_code
        req_conds = Beacon.new.request_conditions(audience['id']).request_conditions
        req_conds = req_conds.each { |rc| rc["audience_id"] = audience['id'] }
        results << req_conds
      end
    end
    return results.flatten
  end

  def conversion_configurations
    results = []

    for pixel in ConversionPixel.all_apn(:advertier_code => partner_code)
      for req_cond in request_conditions
        if pixel['code'] == 
          Audience.find_by_beacon_id(req_cond.audience_id).audience_code
          c = ConversionConfiguration.new(
            :name => pixel['name'], 
            :request_regex => req_cond.request_url_regex,
            :referer_regex => req_cond.referer_url_regex,
            :pixel_code => pixel["code"])
          c.instance_variable_set(:@new_record, false)
          results << c
        end
      end
    end

    return results
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
