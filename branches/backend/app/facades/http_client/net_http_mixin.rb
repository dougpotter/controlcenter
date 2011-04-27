# We use Time.parse, which requires requiring time
require 'time'

module HttpClient::NetHttpMixin
  def get_url_content_length(url)
    do_head(url) do |resp|
      if length = resp['content-length']
        length.to_i
      else
        raise HttpClient::UnsupportedServer, "Content length not found in returned headers"
      end
    end
  end
  
  def get_url_time(url)
    do_head(url) do |resp|
      if time = resp['last-modified']
        Time.parse(time)
      else
        raise HttpClient::UnsupportedServer, "Last modified not found in returned headers"
      end
    end
  end
  
  private
  
  def do_head(url)
    if @debug
      debug_print "Head #{url}"
    end
    
    issue_request(url, :method => :head) do |resp|
      yield resp
    end
  end
end
