module AppnexusClient
  module API

    attr_accessor :agent

    def self.included(base)
      base.instance_eval do
        def acts_as_apn_object(hsh = {})
          @apn_mappings = HashWithIndifferentAccess.new({
            :apn_attr_map => hsh[:apn_attr_map], 
            :non_method_attr_map => hsh[:non_method_attr_map],
            :apn_wrapper => hsh[:apn_wrapper],
            :url_macros => hsh[:url_macros]
          })
          extend ClassMethods
          include InstanceMethods
        end
      end
    end

    module ClassMethods
      attr_accessor :apn_mappings
    end


    module InstanceMethods
      def apn_json
        json_hash = {}

        self.class.apn_mappings[:apn_attr_map].each do |apn_attribute,method|
          json_hash[apn_attribute] = self.send(method)
        end

        json_hash.merge!(self.class.apn_mappings[:non_method_attr_map])

        return ActiveSupport::JSON.encode(self.class.apn_mappings[:apn_wrapper] => json_hash)
      end

      def save_apn
        agent = AppnexusClient::API.new_agent
        agent.url = compiled_url("new")
        agent.post_body = apn_json
        agent.http_post
        if ActiveSupport::JSON.decode(agent.body_str)["response"]["status"] == "OK"
          return true
        else
          return false
        end
      end

      def save_apn!
        agent = AppnexusClient::API.new_agent
        agent.url = compiled_url("new")
        agent.post_body = apn_json
        agent.http_post
        if ActiveSupport::JSON.decode(agent.body_str)["response"]["status"] == "OK"
          return true
        else
          error_msg = 
            ActiveSupport::JSON.decode(agent.body_str)["response"]["error"]
          raise AppnexusRecordInvalid, error_msg
        end
      end

      def compiled_url(action)
        url = 
          APN_CONFIG["displaywords_urls"][self.class.to_s.downcase][action].clone
        for method in self.class.apn_mappings[:url_macros][:new]
          url.sub!("###", self.send(method))
        end
        return url
      end
    end

    def self.new_agent
      require 'curl'
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
