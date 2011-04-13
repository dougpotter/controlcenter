require 'appnexus_client'

APN_CONFIG = YAML.load_file(File.join(RAILS_ROOT, 'config', 'appnexus.yml'))

