module Beacon
  class Client 
    module AudienceAdmin

      # Returns a Hashie::Mash object containing all audiences in the beacon
      #
      # @example Return all audiences
      #   Beacon.new.audiences  # => <#Hashie::Mash audiences=[<#Hashie::Mash active=true id=47 name="F50B" type="xguid-conditional">]>
      def audiences
        get("api/audiences")
      end

      # Returns a Hashie::Mash of the audience with the provided id
      #
      # @param id [Integer] The id of the audience to return
      # @example Get the audience with id 18 as Hashie::Mash object
      #   Beacon.new.audience(18)
      def audience(id)
        get("api/audiences/#{id}")
      end

      # Returns a blank string if successful
      #
      # @param query_hsh [Hash] A hash consisting of attribute_name => attribute_value pairs for the new audience
      # @option query_hash [String] :name the name of the new audience
      # @option query_hash [String] :audience_type the type of the new audience: 'global', 'xguid-conditional', 'request-conditional'
      # @option query_hash [String] :active whether the new audience is active or not: 'true' or 'false'
      # @example Create a new active audience named '64R1' with type 'xguid-conditional'
      #   Beacon.new.new_audience({:name => '64R1', :audience_type => 'xguid-conditional', :active => 'true'})
      def new_audience(query_hsh)
        post("api/audiences?#{query_hsh.url_encode}")
      end

      # Returns a blank string if successful
      #
      # @param id [Integer, String] A beacon id for the audience to be updated
      # @param name [String] The new name of the audience (can be same as old)
      # @param active ["true" | "false"] The new state of the audience (can be same as old
      # @example Update audience with id 19 to have be active and have name 'E4M2'
      #   Beacon.new.update_audience(19, 'E4M2', 'true')
      def update_audience(id, name, active)
        put("api/audiences/#{id}", { :name => name, :active => active })
      end

    end
  end
end
