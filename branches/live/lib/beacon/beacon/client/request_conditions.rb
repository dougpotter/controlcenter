module Beacon
  class Client
    module RequestConditions

      # Returns Hashie::Mash object containing all request conditions for given audience. If the audience ID requested is for an audience not of type request-conditional, a string containig an error message is returned.
      #
      # @param audience_id [Integer,String] The audience for which request conditions will be returned
      # @example  Return all request conditions for audience with beacon ID 4
      #   Beacon.new.request_conditions(4)  # => <#Hashie::Mash request_conditions=[<#Hashie::Mash id=15 referer_url_regex=nil request_url_regex="/aregexyo/">]>
      def request_conditions(audience_id)
        get("audiences/#{audience_id}/request_conditions")
      end

      # Returns the beacon ID of the newly created request condition when successful
      #
      # @param audience_id [Integer,String] The beacon ID for the audience in question
      # @param options [Hash] An hash of :attr => "value" pairs. Must contain at least on :attr => "value" pair.
      # @option options [String] :request_url_regex (nil) The regex on which requests will be matched for this request condition
      # @option options [String] :referer_url_regex (nil) The regex on which referer URLs will be matched for this request condition
      # @example  Create a new request condition
      #   Beacon.new.new_request_condition(2, :referer_regex => "/a.*reg/")
      def new_request_condition(audience_id, *options)
        post(
          "audiences/#{audience_id}/request_conditions?#{options[0].url_encode}"
        )
      end

      # Returns a Hashie::Mash object containing the details of one request condition.
      #
      # @param audience_id [Integer,String] The beacon ID of the audience to which the request condition is associated
      # @param request_condition_id [Integer,String] The beacon ID of the request condition whose details will be returned
      # @example Return details for request condition with beacon ID 3 (which belongs to audience with beacon ID 21)
      #   Beacon.new.request_condition(21, 3) # => <#Hashie::Mash id=3 referer_url_regex=nil request_url_regex="/aregexyo/">
      def request_condition(audience_id, request_condition_id)
        get(
          "audiences/#{audience_id}/request_conditions/#{request_condition_id}"
        )
      end

      # Returns the blank string if successful
      #
      # @param audience_id [Integer,String] The beacon ID of the audience to which the request condition to be updated belongs 
      # @param request_condition_id [Integer,String] The beacon ID of the request condition to be updated
      # @param options [Hash] The hash containing the new attribute values in the formmat :attr => "value"
      # @option options [String] :request_url_regex (nil) The regex on which requests will be matched for this request condition
      # @option options [String] :referer_url_regex (nil) The regex on which referer URLs will be matched for this request condition
      #
      # @example Update request condition with beacon ID 99 (associated with audience 3)
      #   Beacon.new.update_request_condition(3, 99, :request_url_regex => nil, :referer_url_regex => "/a different one/")
      def update_request_condition(audience_id, request_condition_id, *options)
        put(
          "audiences/#{audience_id}/request_conditions/#{request_condition_id}",
          options[0]
        )
      end

      # Returns the blank string if successful
      #
      # @param audience_id [Integer,String] The beacon ID of the audience to which the request condition to be updated belongs 
      # @param request_condition_id [Integer,String] The beacon ID of the request condition to be updated
      # @example  Delete request condition with beacon ID 12 (associated with audience 1)
      #   Beacon.new.delete_request_condition(1, 12)
      def delete_request_condition(audience_id, request_condition_id)
        delete(
          "audiences/#{audience_id}/request_conditions/#{request_condition_id}"
        )
      end

    end
  end
end
