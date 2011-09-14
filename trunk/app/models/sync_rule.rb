class SyncRule < ActiveRecord::Base
  has_no_table

  column :secure_add_pixel
  column :secure_remove_pixel
  column :nonsecure_add_pixel
  column :nonsecure_remove_pixel
  column :sync_period
  column :audience_id

  def save_beacon
    beacon_response = Beacon.new.new_sync_rule(
      audience_id,
      sync_period,
      nonsecure_add_pixel,
      nonsecure_remove_pixel,
      secure_add_pixel,
      secure_remove_pixel
    )

    return ((beacon_response =~ /\d+/) == 0)
  end

  def self.apn_secure_conversion_pixel(conversion_id)
    return "<img src=\"https://secure.adnxs.com/px?"+
      "id=#{conversion_id}\" width=\"1\" height=\"1\" />"
  end

  def self.apn_nonsecure_conversion_pixel(conversion_id)
    return "<img src=\"http://ib.adnxs.com/px?"+
      "id=#{conversion_id}\" width=\"1\" height=\"1\" />"
  end

  def self.apn_secure_add_from_pixel_code(partner_code, conversion_code)
    return self.apn_secure_conversion_pixel(
      ConversionPixel.all_apn(:partner_code => partner_code).select { |px|
        px["code"] == conversion_code
      }[0]["id"]
    )
  end

  def self.apn_nonsecure_add_from_pixel_code(partner_code, conversion_code)
    return self.apn_nonsecure_conversion_pixel(
      ConversionPixel.all_apn(:partner_code => partner_code).select { |px|
        px["code"] == conversion_code
      }[0]["id"]
    )
  end
end
