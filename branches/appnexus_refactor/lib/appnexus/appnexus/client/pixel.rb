module Appnexus
  class Client
    module Pixel
      def pixels_by_id(advertiser_id)
        get("#{endpoint}pixel?advertiser_id=#{advertiser_id}")
      end

      def pixels_by_code(advertiser_code)
        get("#{endpoint}pixel?advertiser_code=#{advertiser_code}")
      end

      def pixel_by_id(advertiser_id, pixel_id)
        get("#{endpoint}pixel?advertiser_id=#{advertiser_id}&id=#{pixel_id}")
      end

      def pixel_by_code(advertiser_code, pixel_code)
        get(
          "#{endpoint}pixel?advertiser_code=#{advertiser_code}&code=#{pixel_code}"
        )
      end

      def new_pixel_by_id(advertiser_id, attributes)
        post(
          "#{endpoint}pixel?advertiser_id=#{advertiser_id}", 
          "pixel" => attributes
        )
      end

      def new_pixel_by_code(advertiser_code, attributes)
        post(
          "#{endpoint}pixel?advertiser_code=#{advertiser_code}", 
          "pixel" => attributes
        )
      end

      def update_pixel_by_id(advertiser_id, pixel_id, attributes)
        put(
          "#{endpoint}pixel?advertiser_id=#{advertiser_id}&id=#{pixel_id}",
          "pixel" => attributes
        )
      end

      def update_pixel_by_code(advertiser_code, pixel_code, attributes)
        put(
          "#{endpoint}pixel?advertiser_code=#{advertiser_code}&code=#{pixel_code}",
          "pixel" => attributes
        )
      end
    end
  end
end
