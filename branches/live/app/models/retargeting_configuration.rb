class RetargetingConfiguration < RedirectConfiguration
  has_no_table

  attr_accessor :name
  attr_accessor :request_regex
  attr_accessor :referer_regex
  attr_accessor :pixel_code
  attr_accessor :request_condition_id
  attr_accessor :sync_rule_id
  attr_accessor :beacon_audience_id

  def self.update(config)
    audience = Audience.find_by_audience_code(config["pixel_code"])
    audience.update_attributes(:description => config["name"])
    Beacon.new.update_audience(audience.beacon_id, config["name"], 0)
    SegmentPixel.new( 
      :name => config["name"],
      :partner_code => audience.partner.partner_code,
      :pixel_code => audience.audience_code,
      :member_id => APN_CONFIG["member_id"]).update_attributes_apn
    request_condition = 
      Beacon.new.request_conditions(audience.beacon_id).request_conditions.first
    Beacon.new.update_request_condition(
      audience.beacon_id,
      request_condition['id'],
      :request_url_regex => config["request_regex"],
      :referer_url_regex => config["referer_regex"])

    return true
  end

  def self.destroy(config)
    audience = Audience.find_by_audience_code(config["pixel_code"])

    SegmentPixel.new( 
      :partner_code => audience.partner.partner_code,
      :pixel_code => audience.audience_code,
      :member_id => APN_CONFIG["member_id"]).delete_apn

    request_condition = 
      Beacon.new.request_conditions(audience.beacon_id).request_conditions.first

    Beacon.new.delete_request_condition(
      audience.beacon_id,
      request_condition['id'])

    for sync_rule in Beacon.new.sync_rules(audience.beacon_id).sync_rules
      Beacon.new.delete_sync_rule(audience.beacon_id, sync_rule['id'])
    end 

    audience.destroy if audience
  end

  def self.create(partner, config)
    audience = Audience.new(
      :description => config.name,
      :audience_code => Audience.generate_audience_code)
    if !audience.save || !audience.save_beacon(partner.partner_code)
      audience.destroy
      errors.add_to_base("Error on Audience save")
      return false    
    end 

    pixel = SegmentPixel.new(
      :name => config.name,
      :pixel_code => audience.audience_code,
      :partner_code => audience.partner.partner_code)
    if !pixel.save_apn
      audience.destroy
      pixel.destroy
      errors.add_to_base("Error on conversion pixel save")
      return false
    end

    request_condition = RequestCondition.new(      
      :request_url_regex => config.request_regex,
      :referer_url_regex => config.referer_regex,
      :audience_id => audience.beacon_id)
    if !request_condition.save_beacon
      audience.destroy
      pixel.destroy
      errors.add_to_base("Error on request condition save")
      return false
    end 

    sync_rule = SyncRule.new(
      :audience_id => audience.beacon_id,
      :sync_period => 7,
      :nonsecure_add_pixel =>
        SyncRule.apn_nonsecure_add_segment(audience.audience_code),
      :secure_add_pixel =>
        SyncRule.apn_secure_add_segment(audience.audience_code))

    if !sync_rule.save_beacon
      audience.destroy
      pixel.destroy
      request_condition.destroy
      @partners = Partner.all
      errors.add_to_base "Error on sync rule save"      
      return false
    end 

    return true
  end
end
