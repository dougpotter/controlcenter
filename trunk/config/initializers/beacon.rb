BEACON_CONFIG = HashWithIndifferentAccess.new(
  YAML.load_file(File.join(RAILS_ROOT, 'config', 'beacon.yml'))
)[RAILS_ENV]

require File.join(RAILS_ROOT, 'lib', 'beacon', 'beacon.rb')
