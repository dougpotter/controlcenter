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

    def put(url, put_data)
      response = ActiveSupport::JSON.decode(
        connection.put(url, put_data).body_str
      )["response"]
      if response["status"] == "OK"
        return response
      elsif response["error_id"] == "NOAUTH"
        auth(@agent)
        put(url, put_data)
      else
        return response["error"]
      end
    end

    def post(url, post_data)
      response = ActiveSupport::JSON.decode(
        connection.post(url, post_data).body_str
      )["response"]
      if response["status"] == "OK"
        return response
      elsif response["error_id"] == "NOAUTH"
        auth(@agent)
        post(url, post_data)
      else
        return response["error"]
      end
    end
  end
end
