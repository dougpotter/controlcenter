module Appnexus
  class Client
    module Advertiser
      def advertisers
        get("#{@endpoint}advertiser")
      end 

      def advertiser(id)
        advertiser_by_id(id)
      end 

      def update_advertiser(id, attributes)
        update_advertiser_by_id(id, attributes)    
      end
    end
  end
end
