class RetargetingSource < AudienceSource
  validates_presence_of :request_regex, :referrer_regex

  validates_absence_of :s3_bucket, :beacon_load_id, :load_status
end
