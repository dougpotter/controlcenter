module PixelGenerator
  # event types hash
  EVENT_TYPES = HashWithIndifferentAccess.new({ 
    :impression => "imp", 
    :imp => "imp", 
    :engagement => "eng",
    :eng => "eng",
    :click => "clk",
    :clk => "clk",
  })

  # pixel type hash
  PIXEL_TYPES = HashWithIndifferentAccess.new({
    :ae => "ae",
    :ad_event => "ae"
  })

  # macros
  AIS_CODE_MACRO = "$${ais_code}"
  PARTNER_CODE_MACRO = "$${partner_code}"
  CAMPAIGN_CODE_MACRO = "$${campaign_code}"
  CREATIVE_CODE_MACRO = "$${creative_code}"
  EVENT_TYPE_MACRO = "$${event_type}"
  MPM_CODE_MACRO = "cpm"
  PIXEL_TYPE_MACRO = "ae"

  # pixel skeleton
  AE_PIXEL_URL = "http://xcdn.xgraph.net/#{PARTNER_CODE_MACRO}/" +
  "#{PIXEL_TYPE_MACRO}/xg.gif?type=#{PIXEL_TYPE_MACRO}&ais=#{AIS_CODE_MACRO}" + 
  "&pid=#{PARTNER_CODE_MACRO}&cid=#{CAMPAIGN_CODE_MACRO}&crid=" + 
  "#{CREATIVE_CODE_MACRO}&mpm=#{MPM_CODE_MACRO}&evt=#{EVENT_TYPE_MACRO}"

  private
  # returns a properly formatted pixel URL as a string
  def self.generate_pixel(creative, event_type, campaign_inventory_config)
    # type check arguments
    if EVENT_TYPES[event_type].nil?
      raise ArgumentError, "event_type must be a known event type"
    elsif !creative.instance_of?(Creative)
      raise ArgumentError, "creative argument must be an instance of Creative"
    elsif !campaign_inventory_config.instance_of?(CampaignInventoryConfig)
      raise ArgumentError, 
        "campaign_inventory_config argument must be an instance of" +  
        "CampaignInventoryConfig"
    else
      event_type = EVENT_TYPES[event_type]
    end

    # query db
    query = CampaignInventoryConfig.find(
      campaign_inventory_config, 
      :include => [ 
        :ad_inventory_source, 
        { :campaign => { :line_item => :partner } }
    ])

    # gather relevant codes
    ais_code = query.ad_inventory_source.ais_code
    partner_code = query.campaign.line_item.partner.partner_code.to_s
    campaign_code = query.campaign.campaign_code
    creative_code = creative.creative_code

    # inject codes into pixel URL skeleton
    pixel = AE_PIXEL_URL.gsub(AIS_CODE_MACRO, ais_code)
    pixel = pixel.gsub(PARTNER_CODE_MACRO, partner_code)
    pixel = pixel.gsub(CAMPAIGN_CODE_MACRO, campaign_code)
    pixel = pixel.gsub(CREATIVE_CODE_MACRO, creative_code)
    pixel = pixel.gsub(EVENT_TYPE_MACRO, event_type)

    return pixel
  end
end
