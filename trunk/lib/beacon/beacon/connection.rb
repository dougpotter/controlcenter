require 'curl'

module Beacon
  module Connection
    def connection
      Curl::Easy
    end
  end
end
