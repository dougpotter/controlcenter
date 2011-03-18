# == Schema Information
# Schema version: 20101220202022
#
# Table name: audiences
#
#  id            :integer(4)      not null, primary key
#  description   :string(255)
#  audience_code :string(255)     not null
#  campaign_id   :integer(4)
#

# Audience is defined as a list of targetable individuals. It 
# encompasses both 'internal' and 'external' audiences - the 
# former being a group we of users we have identified as desirable
# targets and the latter being those among and internal audience
# who have been cookied.
#
class Audience < ActiveRecord::Base
  belongs_to :model
  belongs_to :seed_extraction
  belongs_to :campaign

  has_many :click_counts
  has_many :impression_counts

  has_many :audience_manifests, :dependent => :destroy
  has_many :audience_sources, :through => :audience_manifests

  validates_presence_of :audience_code
  validates_uniqueness_of :audience_code

  acts_as_dimension
  business_index :audience_code, :aka => "aid"

  def audience_code_and_description
    "#{audience_code} - #{description}"
  end

  def iteration_number
    self.audience_manifests.sort_by { |man|
      man.audience_iteration_number
    }.last.audience_iteration_number
  end

  def sources_in_order
    manifests = self.audience_manifests.sort_by { |man|
      man.audience_iteration_number
    }

    sources = []
    for manifest in manifests
      sources << manifest.audience_source
    end
    
    return sources
  end

  def source_type
    if self.audience_sources.empty?
      return nil
    else
      return self.audience_sources.last.class
    end
  end

  def latest_source
    sources_in_order.last
  end

  def update_source(audience_source)
    if self.audience_sources.blank? 
      self.audience_sources << audience_source
    elsif self.latest_source.same_as(audience_source)
      # do nothing
    elsif self.audience_sources.last.class == audience_source.class
      self.audience_sources << audience_source
    else
      raise "audience of type #{self.source_type} cannot be changed to audience of type #{audience_source.class}"
    end
  end

  class << self
    def generate_audience_code
      CodeGenerator.generate_unique_code(
        self,
        :audience_code,
        :length => 4,
        :alphabet => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
      )   
    end 
  end
end
