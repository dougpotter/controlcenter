class ConversionConfiguration < ActiveRecord::Base
  has_no_table

  attr_accessor :name
  attr_accessor :request_regex
  attr_accessor :referer_regex
  attr_accessor :pixel_code

end
