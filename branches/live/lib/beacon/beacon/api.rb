require 'beacon/configuration'
require 'beacon/connection'
require 'beacon/request'
require 'beacon/helper'

module Beacon

  class API
    include Connection
    include Request

    attr_accessor *Configuration::VALID_OPTIONS_KEYS

    def initialize(options = {})
      options = Beacon.options.merge(options)
      Configuration::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end
  end
end
