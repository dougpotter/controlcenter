module Appnexus
  module Configuration 
    VALID_OPTIONS_KEYS = [
      :endpoint,
      :auth_url
    ].freeze

    DEFAULT_ENDPOINT = "http://sand.api.appnexus.com/".freeze
    DEFAULT_AUTH_URL = "http://sand.api.appnexus.com/auth".freeze

    attr_accessor *VALID_OPTIONS_KEYS

    def self.extended(base)
      base.reset
    end

    def reset
      self.endpoint = APN_CONFIG[:api_root_url] || DEFAULT_ENDPOINT
      self.auth_url = "#{APN_CONFIG[:api_root_url]}auth" || DEFAULT_ENDPOINT
    end
  end
end
