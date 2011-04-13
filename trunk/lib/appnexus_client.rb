# The AppnexusClient module could contin all functionality relating to XGraph's
# backend process interaction with AppNexus. Currently some of this functionality
# exists in AppnexusSyncWorkflow. We can discuss at another time whenther to merge
# the two. AppnexusSyncWorkflow does fit nicely into the FETL stack (and
# associated coneptual category), so merging may not be ideal afterall.
#
# The AppnexusClient::API module is intended to expose AppNexus's RESTful API
# to XGCC's backend in order to facilitate easy backend synchronization of XGCC
# objects with their proxies at AppNexus. This will eliminate redundancy going 
# forward - having to enter execution information in both XGCC (to keep track of 
# reporting) and AppNexus's UI (to execute the actual campaign). To ease backend
# synchronization it defines a set of methods on that object that make the CRUD 
# operations on that object at AppNexus as easy as any of the CRUD operations on 
# the object persisted in our own database. CRUD methods currently defined are:
#
# #save_apn
# #save_apn!
#
# AppnexusClient::API is envoked by placing the following 'declaration' at the top 
# of a model class:
#
# acts_as_apn_object
#
# In order for the acts_as_apn_object declaration above to work properly, one must
# provide four confiuration parameters:
#
# :apn_attr_map
#  a hash maping AppNexus attribute names to their XGCC-object equivalents e.g.:
#  { :height => "height", :width => "width", :code => "creative_code" }
#
# :non_method_attr_map
#  a hash mapping any extra attributes (beyond those persisted in XGCC's database) 
#  necessary to persist that object at AppNexus to their values e.g.:
#  { :flash_click_variable => "clickTag" }
#
# :apn_wrapper
#  a translation of XGCC's name for the object to AppNexus's name for the 
#  object e.g.:
#  "creative"
#
# :url_macros
#  mappings for those substitutions 
#  e.g. for the url above, the configuraiton parameter would look lik this:
#  :new => [ :partner_code ]
#
# Finally, in addition to the object level configuraiton parameters specified in
# their respective model class files, AppnexusClient::API looks for a 
# config/appnexus.yml file containing the an authentication URL and credientials. A
# sample file of the appropriate format is provided in config/appnexus.yml.sample.
# Temporarily, due to bad visionon my part, this sample file is not accurate - 
# you also have to define urls in this config file . This is going to change in the 
# next few commits so just bear with me.
#
#  mappings between AppNexus URLs and their associated CRUD actions for that object
#  with '###' indicating requisite substitutions
#  e.g. if the appropriate URL for the NEW action is:
#  https://api.dislaywords.com/creative?advertiser_code=ADVERTISER_CODE
#  the configuration url would be:
#  https://api.dislaywords.com/creative?advertiser_code=###
#
#
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
            :url_macros => hsh[:url_macros],
            :urls => hsh[:urls]
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
        agent.url = apn_action_url("new")
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
        agent.url = apn_action_url("new")
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

      def apn_action_url(action)
        url = APN_CONFIG["api_root_url"] + self.class.apn_mappings[:urls][action]
        return compile_url(url)
      end

      def compile_url(url)
        matcher = /\#\#(.+?)\#\#/
          while url.match(matcher) && method = url.match(matcher)[1]
            url.sub!(matcher, self.send(method))
          end
        return url
      end
    end

    def self.new_agent
      require 'curl'
      @agent = Curl::Easy.new(APN_CONFIG["authentication_url"])
      @agent.enable_cookies = true
      @agent.post_body = APN_CONFIG["authentication_hash"].to_json
      @agent.http_post
      api_token = ActiveSupport::JSON.decode(@agent.body_str)["response"]["token"]
      @agent.headers["Authorization"] = api_token
      return @agent
    end
  end
end
