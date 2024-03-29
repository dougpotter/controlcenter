# The AppnexusClientBindings module is intended to employ our Appnexus API wrapper
# to expose AppNexus's RESTful API to XGCC's backend in an ActiveRecord-y way. This
# module binds methods like RamndomnActiveRecordObject#save_apn to the appropriate 
# Appnexus API wrapper method. We will use this module with each active record 
# object we store in whole or in part at Appnexus.
#
# The methods defined are: 
#
# #save_apn
# #update_attributes_apn
#
# AppnexusClientBindings is configured by placing the following 'declaration' at the
# top of an ActiveRecord model class:
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
# :method_map
#  a hash  mapping http verbs (which correspond to CRUD methods on Appnexus objects)
#  to Appnexus::Client methods and arguments 
#
# Finally, in addition to the object level configuraiton parameters specified in
# their respective model class files, AppnexusClientBindings looks for a 
# config/appnexus.yml file containing the authentication credientials, a base URL,
# and some test parameters. A sample file of the appropriate format is provided in 
# config/appnexus.yml.sample.


module AppnexusClientBindings
  def self.included(base)
    base.instance_eval do
      def acts_as_apn_object(hsh = {})
        @apn_mappings = HashWithIndifferentAccess.new({
          :apn_attr_map => hsh[:apn_attr_map], 
          :non_method_attr_map => hsh[:non_method_attr_map],
          :apn_wrapper => hsh[:apn_wrapper],
          :url_macros => hsh[:url_macros],
          :method_map => hsh[:method_map] || {}
        })
        extend ClassMethods
        include InstanceMethods
      end
    end
  end

  module ClassMethods
    attr_accessor :apn_mappings

    def apn_client_standard_method(http_verb)
      case http_verb
      when "new"
        "new_#{apn_mappings["apn_wrapper"]}"
      when "index"
        "#{apn_mappings["apn_wrapper"].pluralize}"
      when "view"
        "#{apn_mappings["apn_wrapper"]}_by_code"
      when "put"
        "update_#{apn_mappings["apn_wrapper"]}_by_code"
      else
        raise "No default method for http_verb: \"#{http_verb}\""
      end
    end

    def apn_client_method(http_verb)
      apn_mappings[:method_map][http_verb] ?
        apn_mappings[:method_map][http_verb][0] :
        apn_client_standard_method(http_verb)
    end

    def all_apn(*args)
      APPNEXUS.send(apn_client_method("index"), *args)
    end
  end


  module InstanceMethods
    def exists_apn?
      APPNEXUS.send(apn_client_method("view"), *supplemental_args("view")).is_a?(Hash)
    end

    def save_apn
      args = [ supplemental_args("new"), apn_attribute_hash ].flatten
      return APPNEXUS.send(apn_client_method("new"), *args).is_a?(Integer)
    end

    def find_apn
      APPNEXUS.send(apn_client_method("view"), *supplemental_args("view"))
    end

    # because our XGCC's db is the cannonical reference for creatives, instead of
    # taking a new set of parameters and exposing the possibility of having more
    # current information in AppNexus than in XGCC's db, update_attributes_apn 
    # takes no params and simply syncronizes the current state of 'this' with 
    # AppNexus
    def update_attributes_apn
      if self.exists_apn?
        args = [ supplemental_args("put"), apn_attribute_hash ].flatten
        return APPNEXUS.send(apn_client_method("put"), *args).is_a?(String)
      else
        args = [ supplemental_args("new"), apn_attribute_hash ].flatten
        APPNEXUS.send(apn_client_method("new"), *args)
        return APPNEXUS.send(apn_client_method("put"), *args).is_a?(Integer)
      end
    end

    private 

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

    def apn_client_method(http_verb)
      self.class.apn_client_method(http_verb)
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

  end

  def self.env
    return RAILS_ENV
  end
end
