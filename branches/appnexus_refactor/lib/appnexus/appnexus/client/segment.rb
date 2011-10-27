module Appnexus
  class Client
    module Segment
      def segments
        get("#{@endpoint}segment")
      end

      def new_advertiser_segment(advertiser_id, attributes)
        post(
          "#{@endpoint}segment?advertiser_id=#{advertiser_id}", 
          { "segment" => attributes.merge(:member_id => 821) }
        )
      end
    end
  end
end

