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

  def self.apn_secure_pixel(id, type)
    return "<img src=\"https://secure.adnxs.com/#{type}?"+
      "id=#{id}#{type == "px" ? "&t=2" : ""}\" width=\"1\" height=\"1\" />"
  end

  def self.apn_nonsecure_pixel(id, type)
    return "<img src=\"http://ib.adnxs.com/#{type}?"+
      "id=#{id}#{type == "px" ? "&t=2" : ""}\" width=\"1\" height=\"1\" />"
  end

  def self.apn_secure_add_conversion(partner_code, conversion_code)
    return self.apn_secure_pixel(
      ConversionPixel.all_apn(:partner_code => partner_code).select { |px|
        px["code"] == conversion_code
      }[0]["id"],
      "px"
    )
  end

  def self.apn_nonsecure_add_conversion(partner_code, conversion_code)
    return self.apn_nonsecure_pixel(
      ConversionPixel.all_apn(:partner_code => partner_code).select { |px|
        px["code"] == conversion_code
      }[0]["id"],
      "px"
    )
  end

  def self.apn_secure_add_segment(segment_code)
    return self.apn_secure_pixel(
      SegmentPixel.all_apn.select { |px| px["code"] == segment_code }[0]["id"],
      "seg"
    )
  end

  def self.apn_nonsecure_add_segment(segment_code)
    return self.apn_nonsecure_pixel(
      SegmentPixel.all_apn.select { |px| px["code"] == segment_code }[0]["id"],
      "seg"
    )
  end
end
