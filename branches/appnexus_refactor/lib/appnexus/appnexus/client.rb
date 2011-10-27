module Appnexus
  class Client
    include Connection
    include Request

    require "appnexus/client/advertiser"
    require "appnexus/client/segment"

    include Advertiser
    include Segment

    def initialize
      @endpoint = "http://sand.api.appnexus.com/"
      authenticate_connection
    end

    def method_missing(m, *args, &block)
      if match = m.to_s.match(/\A([a-z]+)_by_(id|code)\z/)
        method, object, identifier = match.to_a
        get("#{@endpoint}#{object}?#{identifier}=#{args[0]}")
      elsif match = m.to_s.match(/\Aupdate_([a-z]+)_by_(id|code)\z/)
        method, object, identifier = match.to_a
        put("#{@endpoint}#{object}?#{identifier}=#{args[0]}", { object => args[1] })
      elsif match = m.to_s.match(/\Anew_([a-z]+)\z/)
        method, object, identifier = match.to_a
        post("#{@endpoint}#{object}", { object => args[0] })
      else 
        raise "MethodMissingError: #{m} is not a method"
      end
    end
  end
end
