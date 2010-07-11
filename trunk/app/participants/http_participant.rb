class HttpParticipant < ParticipantBase
  consume(:fetch_directory_listing,
    :input => %w(remote_url),
    :optional_input => %w(http_username http_password lock),
    :sync => true
  ) do
    lock_conditionally(params.input[:lock]) do
      fetch_directory_listing
    end
  end
  
  consume(:fetch_file,
    :input => %w(remote_url local_path),
    :optional_input => %w(http_username http_password lock),
    :sync => true
  ) do
    lock_conditionally(params.input[:lock]) do
      fetch_file
    end
  end
  
  private
  
  def fetch_directory_listing
    output = http_client(
      params.input[:remote_url],
      :http_username => params.input[:http_username],
      :http_password => params.input[:http_password]
    ).fetch(params.input[:remote_url])
    params.output.value = output
  end
  
  def fetch_file
    http_client(
      params.input[:remote_url],
      :http_username => params.input[:http_username],
      :http_password => params.input[:http_password]
    ).download(params.input[:remote_url], params.input[:local_path])
  end
  
  def http_client(url, options)
    default_options = {}
    if RuoteConfiguration.verbose_http
      default_options[:debug] = true
    end
    options = default_options.update(options)
    ThreadLocalHttpClient.instance(options)
  end
end
