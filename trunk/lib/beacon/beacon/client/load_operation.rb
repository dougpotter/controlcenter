module Beacon
  class Client
    module LoadOperation

      # Returns a Hashie::Mash object containing all load operations for a given audience
      #
      # @param audience_id [Integer,String] The beacon id of the audience whose load operations will be returned
      # @example  Return all load operations for audience with beacon ID 1
      #   Beacon.new.load_operations(1)
      def load_operations(audience_id)
        get("audiences/#{audience_id}/load_operations")
      end

      # Returns the empty string on success
      #
      # @param audience_id [Integer,String] The beacon id of the audience for which this load operation is being created
      # @param s3_bucket [String] A string indicating the location, in S3, of the list of xguids for this audience
      # @example  Load the xguids in buckt named xg-live-haddop:16122/model-tsv into audience with beacon ID 888
      #   Beacon.new.load_operation(888, "xg-live-haddop:16122/model-tsv")
      def new_load_operation(audience_id, s3_bucket)
        post(
          "audiences/#{audience_id}/load_operations?"+
          "#{{:s3_xguid_list_prefix => s3_bucket}.url_encode}"
        )
      end

      # Returns the details of a single load operation in a Hashi::Mash object
      #
      # @param audience_id [Integer,String] The beacon ID of the audience that owns the load operation whose details are being returned
      # @param load_operation_id [Integer,String] The beacon ID of the load operation whose details are being returned
      # @example  Retrieve details of load operation with beacon ID 21 (associated with audience 2)
      #   Beacon.new.load_operation(2, 21)  # => <#Hashie::Mash load_operations=[<#Hashie::Mash id=6 s3_xguid_list_prefix="xg-live/prefix" status="pending">]>
      def load_operation(audience_id, load_operation_id)
        get("audiences/#{audience_id}/load_operations/#{load_operation_id}")
      end
    end
  end
end
