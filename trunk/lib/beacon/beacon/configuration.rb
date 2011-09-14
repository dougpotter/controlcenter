module Beacon
  module Configuration

    # An array of valid keys in the options hash when configuring a { Beacon::API }
    VALID_OPTIONS_KEYS = [
      :endpoint
    ].freeze

    # The endpoint that will be used if none is set
    #
    # @note This is configurable to facilitate the use of different endpoints for development, testing, production, etc
    DEFAULT_ENDPOINT = "http://aa.qa.xgraph.net/".freeze

    # @private
    attr_accessor *VALID_OPTIONS_KEYS

    # When this module is extended, reset options to default values
    def self.extended(base)
      base.reset
    end

    def options
      options = {}
      VALID_OPTIONS_KEYS.each{ |k| options[k] = send(k) }
      options
    end

    def reset
      self.endpoint = BEACON_CONFIG[:api_root_url] || DEFAULT_ENDPOINT
    end
  end
end
