module Appnexus
  module Request
    def get(url)
      request("get", url)
    end

    def put(url, put_data)
      request("put", url, :put_data => put_data)
    end

    def post(url, post_data)
      request("post", url, :post_data => post_data)
    end

    def request(verb, url, options = {})
      case verb
      when "get"
        response = connection.get(url)
      when "put"
        response = connection.put(url, options[:put_data])
      when "post"
        response = connection.post(url, options[:post_data])
      end

      parsed_response = ActiveSupport::JSON.decode(response.body_str)["response"]
      if parsed_response["status"] == "OK"
        return parsed_response
      elsif parsed_response["error_id"] == "NOAUTH"
        auth(@agent)
        send(verb, url)
      else
        return parsed_response["error"]
      end
    end
  end
end
