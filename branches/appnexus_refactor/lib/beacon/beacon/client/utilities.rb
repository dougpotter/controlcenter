module Beacon
  class Client
    module Utilities
      def alive?
        response = get("audiences")
        response.is_a?(Array) ? true : false
      end
    end
  end
end
