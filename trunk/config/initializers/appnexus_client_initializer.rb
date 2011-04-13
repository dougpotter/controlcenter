require 'appnexus_client'

APN_CONFIG = HashWithIndifferentAccess.new(
  YAML.load_file(File.join(RAILS_ROOT, 'config', 'appnexus.yml'))
)

APN_FORMAT_MAP = HashWithIndifferentAccess.new({
  :gif => "image",
  :jpeg => "image",
  :jpg => "image",
  :png => "image",
  :swf => "flash"
})

class AppnexusRecordInvalid < StandardError
end

ActiveRecord::Base.class_eval do
    include AppnexusClient::API
end
