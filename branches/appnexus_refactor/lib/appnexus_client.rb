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
            :method_map => hsh[:method_map] || {},
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

      def apn_method(http_verb)
        case http_verb
        when "new"
          custom = apn_mappings[:method_map][:new] ? 
            apn_mappings[:method_map][:new][0] :
            "new_#{apn_mappings["apn_wrapper"]}"
        when "index"
          custom = apn_mappings[:method_map][:index] ? 
            apn_mappings[:method_map][:index][0] :
            "#{apn_mappings["apn_wrapper"].pluralize}"
        when "view"
          custom = apn_mappings[:method_map][:veiw] ? 
            apn_mappings[:method_map][:view][0] :
            "#{apn_mappings["apn_wrapper"]}_by_code"
        when "put"
          custom = apn_mappings[:method_map][:put] ? 
            apn_mappings[:method_map][:put][0] :
            "update_#{apn_mappings["apn_wrapper"]}_by_code"
        else
          raise "Can't find Appnexus method for http_verb: \"#{http_verb}\""
        end
      end


      def all_apn(*args)
        APPNEXUS.send(apn_method("index"), *args)
      end
    end


    module InstanceMethods
      # Older version. Same method as below except returns JSON instead of hash
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

      # Perferred method going forward. Same method as above, just returns a hash 
      # instead of JSON
      def apn_attribute_hash
        json_hash = {}

        self.class.apn_mappings[:apn_attr_map].each do |apn_attribute,method|
          json_hash[apn_attribute] = self.send(method)
        end

        if self.class.apn_mappings[:non_method_attr_map]
          json_hash.merge!(self.class.apn_mappings[:non_method_attr_map])
        end

        return json_hash
      end

      def apn_method(http_verb)
        self.class.apn_method(http_verb)
      end

      def supplemental_args(http_verb)
        args = []
        if components = self.class.apn_mappings[:method_map][http_verb.to_sym]
          for arg in components[1..-1]
            args << self.send(arg)
          end
        end
        return args
      end

      def save_apn
        args = [ supplemental_args("new"), apn_attribute_hash ].flatten
        APPNEXUS.send(apn_method("new"), *args)
      end

      # because our XGCC's db is the cannonical reference for creatives, instead of
      # taking a new set of parameters and exposing the possibility of having more
      # current information in AppNexus than in XGCC's db, update_attributes_apn 
      # takes no params and simply syncronizes the current state of 'this' with 
      # AppNexus
      def update_attributes_apn
        if self.exists_apn?
          args = [ supplemental_args("put"), apn_attribute_hash ].flatten
          return APPNEXUS.send(apn_method("put"), *args).is_a?(String)
        else
          args = [ supplemental_args("new"), apn_attribute_hash ].flatten
          APPNEXUS.send(apn_method("new"), *args)
          return APPNEXUS.send(apn_method("put"), *args).is_a?(String)
        end
      end

      def exists_apn?
        if APPNEXUS.send(apn_method("view"), *supplemental_args("view")).is_a?(Hash)
          return true
        else
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
