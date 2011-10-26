module Beacon
  class Client
    module SyncRules

      # Returns Hashie::Mash object containing sync rules for the audience with id == audience_id
      #
      # @param audience_id [Integer,String] the beacon id for the audience in question
      # @example Retrieve audiences for audience with id = 5
      #   Beacon.new.sync_rules(5)  # => <#Hashie::Mash audiences=[<#Hashie::Mash audience_id=5 nonsecure_add_pixel_url=http://whatever.com nonsecure_remove_pixel_url=http://whatever.com/remove secure_add_pixle_url=https://secure.whatever.com secure_remove_pixel_url=https://secure.whatever.com/remove>]>
      def sync_rules(audience_id)
        get("audiences/#{audience_id}/sync_rules")
      end

      # Returns beacon ID of the newly created sync rule when successful
      #
      # @param audience_id [Integer,String] The beacon id of the audience to which this pixel should be associated
      # @param sync_period [Integer,String] The number of days that may pass since the last sync action, during which time a user my abe considered synchronized within the scope of this sync rule. 
      # @param *_url [String] The url to which this sync rule should direct the user.
      #
      # @example Create sync rules for adding/removing users from audeicne 23 with Appnexus segment 123
      #   Beacon.new.new_sync_rule(
      #     23, 
      #     7, 
      #     http://ib.adnxs.com/sec?add=12345,
      #     http://ib.adnxs.com/sec?remove=12345,
      #     https://secure.ib.adnxs.com/sec?add=12345,
      #     https://secure.ib.adnxs.com/sec?remove=12345
      #   )
      def new_sync_rule(audience_id, sync_period, nonsecure_add_url, nonsecure_remove_url, secure_add_url, secure_remove_url)
        post("audiences/#{audience_id}/sync_rules?#{
          {
            "audience_id" => audience_id,
            "sync_period" => sync_period,
            "nonsecure_add_pixel_url" => nonsecure_add_url,
            "secure_add_pixel_url" => secure_add_url,
            "nonsecure_remove_pixel_url" => nonsecure_remove_url,
            "secure_remove_pixel_url" => secure_remove_url
          }.url_encode
        }")
      end

      # Returns the details of a single sync rule
      #
      # @param audience_id [Integer,String] The beacon ID of the audience to which this sync rule is realted
      # @param sync_rule_id [Integer,String] The beaocn ID of the sync rule whose details will be returned
      # @example Return details for sync rule (related to audeicne with beacon ID 5) with beacon ID 1
      #   Beacon.new.sync_rule(5,1) # => <#Hashie::Mash audiences=[<#Hashie::Mash audience_id=5 nonsecure_add_pixel_url=http://whatever.com nonsecure_remove_pixel_url=http://whatever.com/remove secure_add_pixle_url=https://secure.whatever.com secure_remove_pixel_url=https://secure.whatever.com/remove>]>
      def sync_rule(audience_id, sync_rule_id)
        get("audiences/#{audience_id}/sync_rules/#{sync_rule_id}")
      end

      def update_sync_rule(audience_id, sync_rule_id, sync_period, nonsecure_add_url, nonsecure_remove_url, secure_add_url, secure_remove_url)
        put(
          "audiences/#{audience_id}/sync_rules/#{sync_rule_id}", 
          { 
            "sync_period" => sync_period,
            "nonsecure_add_pixel_url" => nonsecure_add_url,
            "nonsecure_remove_pixel_url" => nonsecure_remove_url,
            "secure_add_pixel_url" => secure_add_url,
            "secure_remove_pixel_url" => secure_remove_url
          }
        )
      end

      # Deletes the sync rule. Returns the empty string if successful
      #
      # @param audience_id [Integer,String] The beacon ID of the audience to which the doomed sync rule is related
      # @param sync_rule_id [Integer,String] The beacon ID of the doomed sync rule
      # @example  Delete sync rule with id 1 (which is related to audience 1)
      #   Beacon.new.delete_sync_rule(1,1)  # => ""
      def delete_sync_rule(audience_id, sync_rule_id)
        delete("audiences/#{audience_id}/sync_rules/#{sync_rule_id}")
      end
    end
  end
end
