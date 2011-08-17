module Beacon
  class Client < API

    require 'beacon/client/audience_admin'

    include Beacon::Client::AudienceAdmin

  end
end
