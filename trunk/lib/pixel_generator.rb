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


  # returns array of strings (which are pixel URLs). Any unrecognized options keys
  # are ignored; however, unknown values associated with known keys will result in
  # an empty return array (because the method will filter out all results not
  # consistent with that value)
  def self.ae_pixels(creative, campaign, options = {})
    # filter on aises
    if options[:aises].blank?
      campaign_inventory_configs = campaign.campaign_inventory_configs
    else
      all_campaign_inventory_configs = 
        campaign.campaign_inventory_configs(:include => :ad_inventory_source)
      campaign_inventory_configs = all_campaign_inventory_configs.select { |cic|
        cic.ad_inventory_source.ais_code.member?(options[:aises])
      }
    end

    # filter on event types
    if options[:event_types].blank?
      event_types = [ :imp, :eng, :clk ]
    else
      event_types = options[:event_types].map { |t| EVENT_TYPES[t] }
      event_types.compact!
    end
   
    # populate pixel array  
    pixels = []
    for cic in campaign_inventory_configs
      for event_type in event_types
        pixels << generate_pixel(creative, event_type, cic)
      end 
    end 

    return pixels
  end

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
