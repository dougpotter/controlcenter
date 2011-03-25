# == Schema Information
# Schema version: 20101220202022
#
# Table name: campaigns
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)     default(""), not null
#  campaign_code :string(255)     default(""), not null
#  start_time    :datetime
#  end_time      :datetime
#  line_item_id  :integer(4)      not null
#

# Campaign is defined as a logical grouping of the elements involved
# in providing our advertising service to a client for a pre-defined
# time period.
class Campaign < ActiveRecord::Base
  has_and_belongs_to_many :geographies

  has_many :campaign_inventory_configs, :dependent => :destroy
  has_many :ad_inventory_sources, { :through => :campaign_inventory_configs, :enforce => true }

  has_and_belongs_to_many :creatives, :enforce => true
  has_one :audience, :dependent => :nullify
  belongs_to :line_item, :enforce => true

  has_many :click_counts, :dependent => :destroy
  has_many :impression_counts, :dependent => :destroy

  validates_presence_of :name, :campaign_code
  validates_uniqueness_of :campaign_code

  after_save :cache_relationships

  acts_as_dimension
  business_index :campaign_code, :aka => "cid"

  def cache_relationships
    for related_class in self.class.enforced_associations
      for related_record in [ self.send(related_class) ].flatten
        cache_string = DimensionCache.cache_string_from_records(
          self, related_record)
          CACHE.write(cache_string, true)
      end
    end
  end

  def campaign_code_and_description
    out = campaign_code
    out += " - #{name}" unless name.blank?
    out
  end

  def partner
    line_item.partner
  end

  def aises
    AdInventorySource.all(
      :joins => { :campaign_inventory_configs => :campaign },
      :conditions => { :campaigns => { :id => self.id } }
    )
  end

  def has_audience?
    if self.audience
      return true
    else
      return false
    end
  end

  def audience_sources
    if self.audience
      self.audience.audience_sources
    else
      return nil
    end
  end

  def source_type
    if self.audience && self.audience.latest_source
      self.audience.latest_source.display_name
    else
      "none"
    end
  end

  def consistent_source(source_as_string)
    if !self.has_audience?
      return true
    elsif self.source_type == source_as_string
      return true
    else
      return false
    end
  end

  def update_audience_source(audience_source)
    if self.has_audience?
      self.audience.update_source(audience_source)
    else
      raise "campaign #{self.name} does not have an audience to update"
    end
  end

  class << self
    def generate_campaign_code
      CodeGenerator.generate_unique_code(
        self,
        :campaign_code,
        :length => 4,
        :alphabet => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
      )
    end
  end
end
