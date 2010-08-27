class HttpClient::Base
  include ExceptionMappingMixin
  
  attr_accessor :logger
  
  # allowed options:
  # :http_username
  # :http_password
  # :timeout
  # :connect_timeout (if :timeout is specified and :connect_timeout is not,
  #   :timeout is used for :connect_timeout as well)
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
