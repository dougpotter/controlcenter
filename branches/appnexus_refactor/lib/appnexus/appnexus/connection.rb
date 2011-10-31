require 'curl'

module Appnexus
  module Connection

    class Agent

      def initialize
        begin
          @agent = Curl::Easy.new(Appnexus.auth_url)
        rescue 
          @agent = Curl::Easy.new(Appnexus.auth_url)
        end
        @agent.enable_cookies = true
        @agent.post_body = APN_CONFIG["authentication_hash"].to_json
        @agent.http_post
        api_token = ActiveSupport::JSON.decode(@agent.body_str)["response"]["token"]
        @agent.headers["Authorization"] = api_token
      end

      def get(url)
        @agent.url = url
        @agent.http_get
        return @agent
      end

      def put(url, put_data)
        @agent.url = url
        @agent.http_put(put_data.to_json)
        return @agent
      end

      def post(url, post_data)
        @agent.url = url
        @agent.post_body = post_data.to_json
        @agent.http_post
        return @agent
      end
    end

    def authenticate_connection
      @@agent = Agent.new
    end


    def connection
      @@agent
    end
  end
end
