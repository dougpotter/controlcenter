namespace :db do
  desc "Create redirect (conversion and sement) configurations from current "+
    "beacon objects. See ConversionConfiguration#ensure_audience_and_apn_pixel "+
    "and RetargetingConfiguration#ensure_audience_and_apn_pixel for more detailse "+
    "on what exactly happens here" 
  task :ensure_redirect_configurations do
    for beacon_audience in Beacon.new.audiences
      if Beacon.new.sync_rules(beacon_audience["id"]).size != 1
        raise "Ambiguous sync rules for beacon audience with id "+
          "#{beacon_audience["id"]}"
      end
      for sync_rule in Beacon.new.sync_rules(beacon_audience["id"])
        pixel_apn_id = sync_rule.nonsecure_add_pixel_url[/px\?id=(\d+)/, 1]
        partner_apn_id = Partner.new(:partner_code => beacon_audience.pid)["id"]
        if Appnexus::Client.conversion_id?(pixel_apn_id)
          ConversionConfiguration.ensure_audience_and_apn_pixel(
            beacon_audience,
            partner_apn_id,
            pixel_apn_id)
        elsif Appnexus::Client.segment_id?(pixel_apn_id)
          RetargetingConfiguration.ensure_audience_and_apn_pixel(
            beacon_audience,
            partner_apn_id,
            pixel_apn_id)
        else
          raise "Don't recognize this apn segment id #{pixel_apn_id} from beacon "+
            "audience #{beacon_audience.id} and sync_rule #{sync_rule["id"]}"
        end
      end
    end
  end
end
