class RetargetingConfiguration < RedirectConfiguration
  has_no_table

  attr_accessor :name
  attr_accessor :request_regex
  attr_accessor :referer_regex
  attr_accessor :pixel_code
  attr_accessor :request_condition_id
  attr_accessor :sync_rule_id
  attr_accessor :beacon_audience_id

  # Examines XGCC databse for an audience corresponding to the beacon audience
  # passed in. If it finds one, it 'remembers' the audience code. If it doesn't
  # find one, it creates one and 'remembers' the audience code. Then, it examines
  # Appnexus for an associated segment. If it finds one, it updates the segment's
  # code to match the audeince code it 'remembered'. If it does not find one, it
  # raises and exception declaring that we have a remote sync that points to nowhere
  def self.ensure_audience_and_apn_pixel(beacon_audience, partner_apn_id, pixel_apn_id)
    if audience = Audience.find_by_beacon_id(beacon_audience["id"])
      pixel_code = audience.audience_code
    else
      audience = Audience.create(
        :description => beacon_audience.name,
        :beacon_id => beacon_audience["id"],
        :audience_code => Audience.generate_audience_code)
      pixel_code = audience.audience_code
    end

    sp = SegmentPixel.new(
      :partner_id =>  partner_apn_id,
      :apn_id => pixel_apn_id).find_apn_by_id
    
    if sp.blank?
      audience.destroy
      raise "remote sync rule (bid: #{beacon_audience["id"]}) pointing to "+
        "non-existant segment (segment's apn id: #{pixel_apn_id}"    
    end

    updated_sp = SegmentPixel.new(
      :apn_id => sp["id"],
      :name => sp["name"],
      :pixel_code => pixel_code,
      :member_id => APN_CONFIG["member_id"])

    if !updated_sp.update_attributes_apn_by_id
      raise "Failed segment pixel update for pixel:\n"+
        ":partner_id => #{updated_sp.partner_id},\n"+
        ":apn_id => #{updated_sp.apn_id},\n"+
        ":name => #{updated_sp.name},\n"+
        ":pixel_code => #{updated_sp.pixel_code} }\n\n"+
        "form beacon audience #{beacon_audience["id"]}"
    end
  end

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
      Beacon.new.request_conditions(audience.beacon_id).first
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
      Beacon.new.request_conditions(audience.beacon_id).first

    Beacon.new.delete_request_condition(
      audience.beacon_id,
      request_condition['id'])

    for sync_rule in Beacon.new.sync_rules(audience.beacon_id)
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

    partner_id = Partner.new(:partner_code => partner.partner_code).find_apn["id"]
    pixel = SegmentPixel.new(
      :name => config.name,
      :pixel_code => audience.audience_code,
      :partner_id => partner_id)
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
