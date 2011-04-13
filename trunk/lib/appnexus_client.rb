module AppnexusClient
  module API
    require 'curl'

    attr_accessor :agent

    def self.new_agent
      @agent = Curl::Easy.new(APN_CONFIG["displaywords_urls"]["auth"])
      @agent.enable_cookies = true
      @agent.post_body = APN_CONFIG["authentication"].to_json
      @agent.http_post
      api_token = ActiveSupport::JSON.decode(@agent.body_str)["response"]["token"]
      @agent.headers["Authorization"] = api_token
      return @agent
    end
  end
end
