class RetargetingSource < AudienceSource
  validates_absence_of :s3_bucket, :beacon_load_id, :load_status

  validate :minimum_one_condition_present

  def minimum_one_condition_present
    if request_regex.blank? && referrer_regex.blank?
      errors.add_to_base(
        "must have at least on of request regex and referrer regex")
    end
  end
end
