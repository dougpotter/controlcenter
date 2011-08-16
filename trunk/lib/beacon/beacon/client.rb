module Beacon
  class Client < API

    def audiences
      get("api/audiences")
    end

    def audience(id)
      get("api/audiences/#{id}")
    end

    def new_audience(query_hsh)
      post("api/audiences?#{query_hsh.url_encode}")
    end

  end
end
