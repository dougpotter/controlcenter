class ConversionConfiguration < RedirectConfiguration
  has_no_table

  attr_accessor :name
  attr_accessor :request_regex
  attr_accessor :referer_regex
  attr_accessor :pixel_code
  attr_accessor :request_condition_id
  attr_accessor :sync_rule_id
  attr_accessor :beacon_audience_id
end
