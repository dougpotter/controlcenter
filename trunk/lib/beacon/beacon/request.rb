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

    def put(path, data)
      request(:put, path, { :put_data => data })
    end

    def delete(path)
      request(:delete, path)
    end

    def request(method, path, options = {})
      url = "#{endpoint}#{path}"
      case method.to_sym
      when :get
        response = connection.http_get(url)
      when :post
        response = connection.http_post(url)
      when :put
        response = connection.http_put(url, options[:put_data].url_encode)
      when :delete
        response = connection.http_delete(url)
      end
      parse_json(response)
    end

    def parse_json(response)
      protocol_header, protocol, response_code, response_message = 
        response.header_str.split(/\r\n/)[0].match(
          /(HTTP\/1\.1) (\d\d\d) (.+)/
        ).to_a
      if response_code == "201"
        return response.header_str.split(/\r\n/)[4].match(/.*\/(\d+)/)[1]
      elsif response_code == "200" && response.body_str == ""
        return ""
      elsif response_code == "200" && response.body_str != ""
        return Hashie::Mash.new(ActiveSupport::JSON.parse(response.body_str))
      elsif response_code == "422"
        return response.body_str
      else
        return response.body_str
      end
    end
  end
end
