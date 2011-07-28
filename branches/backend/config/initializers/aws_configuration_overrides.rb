require 'aws_configuration'
begin
  AppConfigReader.new('aws').apply!
rescue AppConfigReader::ConfigLoadError => e
  if (key = ENV['AWS_ACCESS_KEY_ID']) && (secret = ENV['AWS_SECRET_ACCESS_KEY']) &&
    !(key = key.strip).blank? && !(secret = secret.strip).blank?
  then
    AwsConfiguration.access_key_id = key
    AwsConfiguration.secret_access_key = secret
  else
    warn "Failed to load aws config: #{e.class}: #{e.message}"
  end
end
