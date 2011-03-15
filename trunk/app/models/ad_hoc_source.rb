class AdHocSource < AudienceSource
  validates_presence_of :s3_bucket, :load_status, :beacon_load_id

  validates_absence_of :referrer_regex, :request_regex
end
