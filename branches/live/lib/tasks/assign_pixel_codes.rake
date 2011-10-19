namespace :db do
  desc "Create redirect (conversion and sement) configurations from current "+
    "beacon objects. See ConversionConfiguration#ensure_audience_and_apn_pixel "+
    "and RetargetingConfiguration#ensure_audience_and_apn_pixel for more detailse "+
    "on what exactly happens here" 
  task :ensure_redirect_configurations => :environment do
    apn_sync_log_file = File.open(
      File.join(RAILS_ROOT, "log", "appnexus_tasks.log"),
      'w'
    )
    apn_sync_log = AppnexusSyncLog.new(apn_sync_log_file)

    for beacon_audience in Beacon.new.audiences
      apn_sync_log.info("Working on beacon audience #{beacon_audience["id"]}")
      if beacon_audience.pid.blank?
        apn_sync_log.info("Beacon audience #{beacon_audience["id"]} has no PID, "+
        "skipping")
        next
      end
      for sync_rule in Beacon.new.sync_rules(beacon_audience["id"])
        apn_sync_log.info("Working on sync rule #{sync_rule["id"]} for beacon "+
          "audience #{beacon_audience["id"]}")
        partner_apn_id = Partner.new(
          :partner_code => beacon_audience.pid
        ).find_apn["id"]
        if conversion_apn_id = sync_rule.nonsecure_add_pixel_url[/px\?id=(\d+)/, 1]
          if !AppnexusClient::API.conversion_id?(beacon_audience.pid, conversion_apn_id)
            apn_sync_log.error("Don't recognize the apn conversion id "+
            "#{conversion_apn_id} from sync_rule #{sync_rule["id"]}")
          else
            ConversionConfiguration.ensure_audience_and_apn_pixel(
              beacon_audience,
              partner_apn_id,
              conversion_apn_id)
              apn_sync_log.info("Configured conversion with Appnexus ID "+
                "#{conversion_apn_id}")
          end
        elsif segment_apn_ids = sync_rule.nonsecure_add_pixel_url[/seg\?add=((\d+\,*)+)/, 1]
          for segment_apn_id in segment_apn_ids.split(",")
            if !AppnexusClient::API.segment_id?(segment_apn_id)
              apn_sync_log.error("Don't recognize the apn segment id "+
              "#{segment_apn_id} from sync_rule #{sync_rule["id"]}")
            else
              RetargetingConfiguration.ensure_audience_and_apn_pixel(
                beacon_audience,
                partner_apn_id,
                segment_apn_id)
              apn_sync_log.info("Configured segment with Appnexus ID "+
                "#{segment_apn_id}")
            end
          end
        else
          apn_sync_log.warn("Don't recognize sync rule #{sync_rule["id"]}:\n"+
            "\tnonsecure add pixel: #{sync_rule["nonsecure_add_pixel_url"]}\n"+
            "\tsecure add pixel: #{sync_rule["secure_add_pixel_url"]}\n"
          )
        end
      end
    end
    apn_sync_log.close
  end
end
