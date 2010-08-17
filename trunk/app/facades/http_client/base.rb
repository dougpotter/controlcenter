class HttpClient::Base
  # allowed options:
  # :http_username
  # :http_password
  # :timeout
  # :connect_timeout (if :timeout is specified and :connect_timeout is not,
  #   :timeout is used for :connect_timeout as well)
  # :debug
  def initialize(options={})
    raise NotImplemented
  end
  
  def fetch(url)
    raise NotImplemented
  end
  
  def download(url, local_path)
    raise NotImplemented
  end
  
  private
  
  def map_exceptions(exception_map, url)
    begin
      yield
    rescue Exception => original_exc
      exception_map.each do |from_cls, to_cls|
        if original_exc.is_a?(from_cls)
          convert_and_raise(original_exc, to_cls, url)
        end
      end
      
      # not mapped, raise original exception
      raise
    end
  end
  
  def convert_and_raise(original_exc, converted_cls, url)
    new_message = "#{original_exc.message} (#{original_exc.class})"
    exc = converted_cls.new(
      new_message,
      :url => url,
      :original_exception_class => original_exc.class
    )
    exc.set_backtrace(original_exc.backtrace)
    raise exc
  end
end
