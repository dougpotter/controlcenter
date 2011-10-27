module Appnexus
  class Client
    include Connection
    include Request

    def initialize
      @endpoint = "http://sand.api.appnexus.com/"
      authenticate_connection
    end

    def advertisers
      get("#{@endpoint}advertiser")
    end

    def advertiser(id)
      advertiser_by_id(id)
    end

    def method_missing(m, *args, &block)
      if match = m.to_s.match(/^([a-z^_]+)_by_(id|code)$/)
        method, object, identifier = match.to_a
        get("#{@endpoint}#{object}?#{identifier}=#{args[0]}")
      end
    end
  end
end
