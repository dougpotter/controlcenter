class RequestCondition < ActiveRecord::Base
  has_no_table

  column :request_url_regex
  column :referer_url_regex
  column :audience_id

  def save_beacon
    beacon_response = Beacon.new.new_request_condition(
      audience_id,
      :request_url_regex => request_url_regex,
      :referer_url_regex => referer_url_regex)

    return ((beacon_response.to_s =~ /^\d+$/) == 0)
  end
end
