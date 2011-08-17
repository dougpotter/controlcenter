module Beacon
  class Client < API

    require 'beacon/client/audience_admin'
    require 'beacon/client/sync_rules'
    require 'beacon/client/request_conditions'

    include Beacon::Client::AudienceAdmin
    include Beacon::Client::SyncRules
    include Beacon::Client::RequestConditions

  end
end
