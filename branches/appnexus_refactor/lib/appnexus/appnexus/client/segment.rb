module Appnexus
  class Client
    module Segment
      def segments
        get("segment")["segments"]
      end

      def new_advertiser_segment(advertiser_id, attributes)
        post(
          "segment?advertiser_id=#{advertiser_id}", 
          { "segment" => attributes.merge(:member_id => 821) }
        )["segment"]
      end
    end
  end
end

