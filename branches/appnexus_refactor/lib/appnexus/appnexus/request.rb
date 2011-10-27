module Appnexus
  module Request
    def get(url)
      response = ActiveSupport::JSON.decode(
        connection.get(url).body_str
      )["response"]
      if response["status"] == "OK"
        return response
      elsif response["error_id"] == "NOAUTH"
        auth(@agent)
        get(url)
      else
        return response["error"]
      end
    end
  end
end
