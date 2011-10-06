module Beacon
  class Client
    module Utilities
      def alive?
        response = get("audiences")
        response.is_a?(Hashie::Mash) ? true : false
      end
    end
  end
end
