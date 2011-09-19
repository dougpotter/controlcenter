module Beacon
  class Client < API

    require 'beacon/client/audience_admin'
    require 'beacon/client/sync_rules'
    require 'beacon/client/request_conditions'
    require 'beacon/client/load_operation'
    require 'beacon/client/utilities'

    include Beacon::Client::AudienceAdmin
    include Beacon::Client::SyncRules
    include Beacon::Client::RequestConditions
    include Beacon::Client::LoadOperation
    include Beacon::Client::Utilities

  end
end
