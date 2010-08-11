if File.exist?(File.join( RAILS_ROOT, "config/appwall.yml" )) &&
    appwall_config = YAML::load(
      File.open( File.join( RAILS_ROOT, "config/appwall.yml" ) ) )[Rails.env]
  
  APPWALL_USERNAME = appwall_config["username"]
  APPWALL_PASSWORD_HASH = appwall_config["password_hash"]
end
