module Appnexus
  class Client
    include Connection
    include Request

    def initialize
      @endpoint = "http://sand.api.appnexus.com/"
      authenticate_connection
    end

    def partners
      get("#{@endpoint}advertiser")
    end
  end
end
