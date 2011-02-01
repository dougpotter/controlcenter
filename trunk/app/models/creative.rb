# == Schema Information
# Schema version: 20101220202022
#
# Table name: creatives
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  media_type         :string(255)
#  creative_size_id   :integer(4)      not null
#  creative_code      :string(255)     not null
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer(4)
#  image_updated_at   :datetime
#

# Creative is the visual component of an ad
class Creative < ActiveRecord::Base
  belongs_to :creative_size
  belongs_to :line_item
  has_many :click_counts
  has_many :impression_counts
  
  has_many :creative_inventory_configs
  has_many :campaign_inventory_configs, :through => :creative_inventory_configs

  has_and_belongs_to_many :campaigns
  has_s3_attachment :image, "test-creatives", ":attachment/:id/:style/:filename"
  
  validates_presence_of :creative_code, :creative_size_id
  validates_uniqueness_of :creative_code
  validates_numericality_of :creative_size_id

  acts_as_dimension
  business_index :creative_code, :aka => "crid"

  def <=>(another_creative)
    self.creative_code <=> another_creative.creative_code 
  end

  def size_name
    creative_size.common_name
  end

  def campaign_descriptions
    s = campaigns.map { |c|
      c.campaign_code_and_description
    }.join("; ")
  end
  
  def creative_code_and_name
    if description == ""
      creative_code
    else
      "#{creative_code} - #{description}"
    end
  end

  def fully_configured?
    fully_configured = true
    self.creative_inventory_configs.each do |c|
    end
  end
end
