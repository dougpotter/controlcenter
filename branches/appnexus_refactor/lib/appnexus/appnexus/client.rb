module Appnexus
  class Client
    include Connection
    include Request

    require "appnexus/client/advertiser"
    require "appnexus/client/segment"
    require "appnexus/client/pixel"

    include Advertiser
    include Segment
    include Pixel

    def initialize
      authenticate_connection
    end

    def method_missing(m, *args, &block)
      if match = m.to_s.match(/\A([a-z]+)_by_(id|code)\z/)
        method, object, identifier = match.to_a
        get("#{object}?#{identifier}=#{args[0]}")[object]
      elsif match = m.to_s.match(/\Aupdate_([a-z]+)_by_(id|code)\z/)
        method, object, identifier = match.to_a
        put("#{object}?#{identifier}=#{args[0]}", { object => args[1] })[object]
      elsif match = m.to_s.match(/\Anew_([a-z]+)\z/)
        method, object, identifier = match.to_a
        post("#{object}", { object => args[0] })[object]
      else 
        raise "MethodMissingError: #{m} is not a method"
      end
    end
  end
end
