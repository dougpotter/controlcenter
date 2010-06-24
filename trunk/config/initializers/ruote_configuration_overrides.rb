config_path = Rails.root.join('config/ruote_host.yml')
if File.exist?(config_path)
  overrides = YAML.load(File.read(config_path))
  overrides.each do |key, value|
    RuoteConfiguration.send("#{key}=", value)
  end
end
