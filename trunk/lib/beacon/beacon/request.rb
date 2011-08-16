require 'json'
require 'hashie'

module Beacon
  module Request
    def get(path) 
      request(:get, path)
    end

    def post(path)
      request(:post, path)
    end

    def request(method, path)
      url = "#{endpoint}#{path}"
      case method.to_sym
      when :get
        response = connection.http_get(url).body_str
      when :post
        response = connection.http_post(url).body_str
      end
      parse_json(response)
    end

    def parse_json(response)
      begin
        return Hashie::Mash.new(JSON.parse(response))
      rescue JSON::ParserError
        return response
      end
    end
  end
end
