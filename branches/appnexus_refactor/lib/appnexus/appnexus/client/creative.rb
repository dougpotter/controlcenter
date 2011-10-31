module Appnexus
  class Client
    module Creative
      def creatives
        get("creative")["creatives"]
      end
    end
  end
end
