namespace :db do
  desc "Create redirect (conversion and sement) configurations from current "+
    "beacon objects. See ConversionConfiguration#ensure_audience_and_apn_pixel "+
    "and RetargetingConfiguration#ensure_audience_and_apn_pixel for more detailse "+
    "on what exactly happens here" 
  task :ensure_redirect_configurations => :environment do
    for beacon_audience in Beacon.new.audiences
      if Beacon.new.sync_rules(beacon_audience["id"]).size != 1
        raise "Ambiguous sync rules for beacon audience with id "+
          "#{beacon_audience["id"]}"
      end
      for sync_rule in Beacon.new.sync_rules(beacon_audience["id"])
        partner_apn_id = Partner.new(
          :partner_code => beacon_audience.pid
        ).find_apn["id"]
        if (conversion_apn_id = sync_rule.nonsecure_add_pixel_url[/px\?id=(\d+)/, 1]) &&
          AppnexusClient::API.conversion_id?(beacon_audience.pid, conversion_apn_id)
          ConversionConfiguration.ensure_audience_and_apn_pixel(
            beacon_audience,
            partner_apn_id,
            conversion_apn_id)
        elsif (segment_apn_id = sync_rule.nonsecure_add_pixel_url[/seg\?id=(\d+)/, 1]) &&
          AppnexusClient::API.segment_id?(segment_apn_id)
          RetargetingConfiguration.ensure_audience_and_apn_pixel(
            beacon_audience,
            partner_apn_id,
            segment_apn_id)
        else
          raise "Don't recognize this apn segment id "+
          "#{conversion_apn_id ? conversion_apn_id : segment_apn_id} from beacon "+
            "audience #{beacon_audience.id} and sync_rule #{sync_rule["id"]}"
        end
      end
    end
  end
end
