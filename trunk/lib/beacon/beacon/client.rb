module Beacon
  class Client < API

    require 'beacon/client/audience_admin'
    require 'beacon/client/sync_rules'

    include Beacon::Client::AudienceAdmin
    include Beacon::Client::SyncRules

  end
end
