class HttpClient::Base
  include ExceptionMappingMixin
  
  attr_accessor :logger
  
  # allowed options:
  # :http_username
  # :http_password
  # :timeout
  # :debug
  # :logger
  def initialize(options={})
    @logger = options[:logger] || Workflow.default_logger
  end
  
  def fetch(url)
    raise NotImplemented
  end
  
  def download(url, local_path)
    raise NotImplemented
  end
  
  private
  
  def debug_print(msg)
    logger.debug(self.class.name) { msg }
  end
end
