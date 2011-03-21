class AdHocSource < AudienceSource
  validates_presence_of :s3_bucket

  validates_absence_of :referrer_regex, :request_regex

  def same_as(other_source)
    self.s3_bucket == other_source.s3_bucket
  end
end
