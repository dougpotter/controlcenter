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
  belongs_to :partner
  has_many :click_counts
  has_many :impression_counts

  has_many :creatives_line_items, :dependent => :delete_all
  has_many :line_items, :through => :creatives_line_items

  has_many :creative_inventory_configs, :dependent => :delete_all
  has_many :campaign_inventory_configs, :through => :creative_inventory_configs

  has_and_belongs_to_many :campaigns
  has_s3_attachment :image, "test-creatives", ":attachment/:id/:style/:filename"

  validates_presence_of :creative_code, :creative_size_id
  validates_uniqueness_of :creative_code
  validates_numericality_of :creative_size_id

  acts_as_dimension
  business_index :creative_code, :aka => "crid"

  acts_as_apn_object :apn_attr_map => { 
      :width => "width",
      :height => "height",
      :code => "creative_code",
      :file_name => "image_file_name",
      :name => "image_file_name",
      :content => "image_base64",
      :format => "apn_format" },
    :non_method_attr_map => {
      :flash_click_variable => "clickTag",
      :track_clicks => "true" },
    :apn_wrapper => "creative",
    :urls => {
      :index => "creative?advertiser_code=##partner_code##",
      :delete => "creative?advertiser_code=##partner_code##&code=##creative_code##",
      :new => "creative?advertiser_code=##partner_code##" }

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
    if self.name == ""
      creative_code
    else
      "#{creative_code} - #{self.name}"
    end
  end

  def ae_pixels(campaign, options = {})
    PixelGenerator.ae_pixels(self, campaign, options)
  end

  def has_image?
    return !self.image_file_name.nil?
  end

  def configured?(campaign_inventory_config)
    return !CreativeInventoryConfig.all(
      :conditions => {
      :creative_id => self.id,
      :campaign_inventory_config_id => campaign_inventory_config.id
    }).empty?
  end

  def configure(campaign_inventory_config)
    if !self.campaign_inventory_configs.member?(campaign_inventory_config)
      self.campaign_inventory_configs << campaign_inventory_config
    end
  end

  def unconfigure(campaign_inventory_config)
    self.campaign_inventory_configs.delete(campaign_inventory_config)
  end

  def width
    self.creative_size.width.to_i.to_s
  end

  def height
    self.creative_size.height.to_i.to_s
  end

  def apn_format
    begin
      return APN_FORMAT_MAP[image_file_name.match(/.+\.(.+)/)[1]]
    rescue NoMethodError
      nil
    end
  end

  def image_base64
    image_contents = ""
    f = image.to_file
    if self.new_record?
      f.open
      image_contents = f.read
      f.close
    else
      image_contents = f.read
    end
    return ActiveSupport::Base64.encode64(image_contents)
  end

  def partner_code
    self.partner.partner_code.to_s
  end

  def self.generate_creative_code
    CodeGenerator.generate_unique_code(
      self,
      :creative_code,
      :length => 5,
      :alphabet => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
    )
  end
end
