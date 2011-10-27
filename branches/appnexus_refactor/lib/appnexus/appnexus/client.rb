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

    def update_advertiser(id, attributes)
      update_advertiser_by_id(id, attributes)
    end

    def method_missing(m, *args, &block)
      if match = m.to_s.match(/\A([a-z]+)_by_(id|code)\z/)
        method, object, identifier = match.to_a
        get("#{@endpoint}#{object}?#{identifier}=#{args[0]}")
      elsif match = m.to_s.match(/\Aupdate_([a-z]+)_by_(id|code)\z/)
        method, object, identifier = match.to_a
        put("#{@endpoint}#{object}?#{identifier}=#{args[0]}", { object => args[1] })
      end
    end
  end
end
