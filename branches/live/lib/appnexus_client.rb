# The AppnexusClient module could contin all functionality relating to XGraph's
# backend process interaction with AppNexus. Currently some of this functionality
# exists in AppnexusSyncWorkflow. We can discuss at another time whenther to merge
# the two. AppnexusSyncWorkflow does fit nicely into the FETL stack (and
# associated conceptual category), so merging may not be ideal afterall.
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
# #delete_apn
# #update_attributes_apn
#
# AppnexusClient::API is invoked by placing the following 'declaration' at the top 
# of an ActiveRecord model class:
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
# :urls
#  a hash  mapping AppNexus URL extensions to their associated CRUD actions for that
#  object, with macros indicating where a substitution should take place e.g.:
#
#  :new => creative?advertiser_code=##partner_code##
#
#  would indicate the new action for a creative uses the root URL defined in the
#  configuration file (see below) plus this extension with the result of 
#  Creative#partner_code substituted for the string '##partner_code##'
#
# Finally, in addition to the object level configuraiton parameters specified in
# their respective model class files, AppnexusClient::API looks for a 
# config/appnexus.yml file containing the authentication credientials, a base URL,
# and some test parameters. A sample file of the appropriate format is provided in 
# config/appnexus.yml.sample.


module AppnexusClient
  module API

    @@agent = nil

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

      def apn_action_url(action, *substitutions)
        if path = apn_mappings[:urls][action]
          substitutions = [substitutions].flatten
          substitutions.map! { |subs| subs.to_s }
          matcher = /\#\#(.+?)\#\#/
          url = APN_CONFIG["api_root_url"] + apn_mappings[:urls][action]
          macros = url.scan(matcher).size
          if macros != substitutions.size
            raise "number of macros and number of substitutions in AppNexus URL" + 
              " don't agree"
          else
            while url.match(matcher)
              url.sub!(matcher, substitutions.shift)
            end
          end
        else
          raise "Appnexus action URL undefined for #{action}"
        end

        return url
      end

      def all_apn(*substitutions)
        agent = AppnexusClient::API.new_agent
        if substitutions.blank?
          agent.url = apn_action_url(:index)
        else
          agent.url = apn_action_url(:index, substitutions[0].values)
        end
        agent.http_get


        result = ActiveSupport::JSON.decode(
          agent.body_str
        )["response"][@apn_mappings[:apn_wrapper].pluralize]

        result ? result : []
      end

      def delete_url(object_hash)
        url = apn_mappings[:urls][:delete_by_apn_ids].clone
        necessary_attributes = url.scan(/(?:\?|\&)(.+?)=/).flatten
        substitutions = []
        for attribute in necessary_attributes
          substitutions << object_hash[attribute.to_s]
        end

        apn_action_url(:delete_by_apn_ids, substitutions)
      end

      def delete_by_apn_id(*substitutions)
        token = AppnexusClient::API.new_agent.headers["Authorization"]
        agent = Curl::Easy.http_delete(delete_url(substitutions[0])) do |a|
          a.headers["Authorization"] = token
        end

        result = ActiveSupport::JSON.decode(
          agent.body_str
        )["response"][@apn_mappings[:apn_wrapper].pluralize]
      end

      def delete_by_code_url(*object_hash)
        if object_hash.is_a?(Array)
          object_hash = object_hash[0]
        end
        url = apn_mappings[:urls][:delete].clone
        necessary_attributes = url.scan(/(?:\?|\&)(.+?)=/).flatten
        substitutions = []
        for attribute in necessary_attributes
          substitutions << object_hash[attribute.to_s]
        end

        apn_action_url(:delete, substitutions)
      end

      def delete_apn(*substitutions)
        token = AppnexusClient::API.new_agent.headers["Authorization"]
        agent = Curl::Easy.http_delete(delete_by_code_url(substitutions[0])) do |a|
          a.headers["Authorization"] = token
        end
      end

      def delete_all_apn(*filter)

        if RAILS_ENV == "production"
          raise "ATTEMPTING TO DELETE PRODUCTION DATA AT APPNEXUS." +
            " THIS MUST BE DONE THROUGH THE APPNEXUS UI" 
        end

        if filter
          objects = all_apn(filter[0]).map { |o| o.merge(filter[0]) }
        else
          objects = all_apn
        end

        agent = AppnexusClient::API.new_agent

        for object in objects
          agent.url = delete_url(object)
          agent.http_delete
        end

        if filter
          return all_apn(filter[0]).size == 0
        else
          return all_apn.size == 0
        end
      end
    end


    module InstanceMethods
      def apn_json
        json_hash = {}

        self.class.apn_mappings[:apn_attr_map].each do |apn_attribute,method|
          json_hash[apn_attribute] = self.send(method)
        end

        if self.class.apn_mappings[:non_method_attr_map]
          json_hash.merge!(self.class.apn_mappings[:non_method_attr_map])
        end

        return ActiveSupport::JSON.encode(
          self.class.apn_mappings[:apn_wrapper] => json_hash
        )
      end

      def save_apn
        agent = AppnexusClient::API.new_agent
        agent.url = apn_action_url("new")
        agent.post_body = apn_json
        agent.http_post
        if ActiveSupport::JSON.decode(agent.body_str)["response"]["status"] == "OK"
          return true
        else
          self.errors.add_to_base(
            ActiveSupport::JSON.decode(agent.body_str)["response"]["error"] + 
            " at Appnexus"
          )
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
            ActiveSupport::JSON.decode(agent.body_str)["response"]["error"] +
            " at Appnexus"
          self.errors.add_to_base(
            error_msg
          )
          raise AppnexusRecordInvalid, error_msg
        end
      end

      # because our XGCC's db is the cannonical reference for creatives, instead of
      # taking a new set of parameters and exposing the possibility of having more
      # current information in AppNexus than in XGCC's db, update_attributes_apn 
      # takes no params and simply syncronizes the current state of 'this' with 
      # AppNexus
      def update_attributes_apn
        agent = AppnexusClient::API.new_agent
        if self.exists_apn?
          agent.url = apn_action_url("update")
          agent.http_put(apn_json)
        else
          agent.url = apn_action_url("new")
          agent.post_body = apn_json
          agent.http_post
        end

        if ActiveSupport::JSON.decode(agent.body_str)["response"]["status"] == "OK"
          return true
        else
          error_msg =
            ActiveSupport::JSON.decode(agent.body_str)["response"]["error"]
          self.errors.add_to_base(
            error_msg
          )
          return false
        end
      end

      def update_attributes_apn_by_id
        agent = AppnexusClient::API.new_agent
        if self.exists_apn?
          agent.url = apn_action_url("update_by_id")
          agent.http_put(apn_json)
        else
          agent.url = apn_action_url("new")
          agent.post_body = apn_json
          agent.http_post
        end

        if ActiveSupport::JSON.decode(agent.body_str)["response"]["status"] == "OK"
          return true
        else
          error_msg =
            ActiveSupport::JSON.decode(agent.body_str)["response"]["error"]
          self.errors.add_to_base(
            error_msg
          )
          return false
        end
      end

      def delete_by_apn_id
        token = AppnexusClient::API.new_agent.headers["Authorization"]
        agent = Curl::Easy.http_delete(apn_action_url(:delete_by_apn_ids)) do |a|
          a.headers["Authorization"] = token
        end

        if ActiveSupport::JSON.decode(agent.body_str)["response"]["status"] == "OK"
          return true
        else
          return false
        end
      end

      def delete_apn
        token = AppnexusClient::API.new_agent.headers["Authorization"]
        agent = Curl::Easy.http_delete(apn_action_url(:delete)) do |a|
          a.headers["Authorization"] = token
        end

        if ActiveSupport::JSON.decode(agent.body_str)["response"]["status"] == "OK"
          return true
        else
          return false
        end
      end

      def exists_apn?
        agent = AppnexusClient::API.new_agent
        agent.url = apn_action_url(:view)
        agent.http_get

        if ActiveSupport::JSON.decode(agent.body_str)["response"]["status"] == "OK"
          return true
        elsif defined_action?(:view_by_id)
          agent.url = apn_action_url(:view_by_id)
          agent.http_get
          if ActiveSupport::JSON.decode(agent.body_str)["response"]["status"] == "OK"
            return true
          else
            return false
          end
        else
          return false
        end
      end

      def defined_action?(action)
        begin
          apn_action_url(action)
          return true
        rescue
          return false
        end
      end

      def find_apn
        agent = AppnexusClient::API.new_agent
        agent.url = apn_action_url(:view)
        agent.http_get

        return ActiveSupport::JSON.decode(
          agent.body_str
        )["response"][self.class.apn_mappings[:apn_wrapper]]
      end

      def find_apn_by_id
        agent = AppnexusClient::API.new_agent
        agent.url = apn_action_url(:view_by_id)
        agent.http_get

        return ActiveSupport::JSON.decode(
          agent.body_str
        )["response"][self.class.apn_mappings[:apn_wrapper]]
      end

      def apn_action_url(action)
        if self.class.apn_mappings[:urls][action]
          url = APN_CONFIG["api_root_url"] + self.class.apn_mappings[:urls][action]
        else
          raise "Appnexus action URL undefined for #{action}"
        end
        return compile_url(url)
      end

      def compile_url(url)
        matcher = /\#\#(.+?)\#\#/
          while url.match(matcher) && method = url.match(matcher)[1]
            url.sub!(matcher, self.send(method).to_s)
          end
        return url
      end
    end

    # Module level methods

    def self.conversion_id?(partner_code, pixel_apn_id)
      for pixel in ConversionPixel.all_apn(:partner_code => partner_code)
        return true if pixel["id"].to_s == pixel_apn_id.to_s
      end
      return false
    end

    def self.segment_id?(pixel_apn_id)
      for pixel in SegmentPixel.all_apn
        return true if pixel["id"].to_s == pixel_apn_id.to_s
      end
      return false
    end

    def self.issue_get(object, *filters)
      url = "#{APN_CONFIG[:api_root_url]}#{object}"
      if !filters.empty?
        url += "?"
        filters.each do |attribute, value|
          url += "#{attribute}=#{value}"
        end
      end
      self.new_agent
      @@agent.url = url
      @@agent.http_get
      return nil
    end

    def self.method_missing(method_sym, *filters, &block)
      if method_sym.to_s =~ /^get_(.*)$/
        self.issue_get($1.gsub("_", "-"), filters)
      else
        raise NoMethodError, "undefined method #{method_sym} for #{self}"
      end
    end

    def self.env
      return RAILS_ENV
    end

    def self.new_agent
      require 'curl'
      begin
      @@agent = Curl::Easy.new(APN_CONFIG["api_root_url"] + "auth")
      rescue Curl::Err::ConnectionFailedError
        @@agent = Curl::Easy.new(APN_CONFIG["api_root_url"] + "auth")
      end
      @@agent.enable_cookies = true
      @@agent.post_body = APN_CONFIG["authentication_hash"].to_json
      @@agent.http_post
      api_token = ActiveSupport::JSON.decode(@@agent.body_str)["response"]["token"]
      @@agent.headers["Authorization"] = api_token
      return @@agent
    end
  end
end
