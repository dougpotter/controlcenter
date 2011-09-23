class RequestCondition < ActiveRecord::Base
  has_no_table

  column :request_url_regex
  column :referer_url_regex
  column :audience_id

  def save_beacon
    if request_url_regex.blank? && referer_url_regex.blank?
      self.errors.add_to_base(
        "One of request url regex and referer url regex must be populated for"+
        " request condition")
        return false
    end

    beacon_response = Beacon.new.new_request_condition(
      audience_id,
      :request_url_regex => request_url_regex,
      :referer_url_regex => referer_url_regex)

    return ((beacon_response.to_s =~ /^\d+$/) == 0)
  end
end
