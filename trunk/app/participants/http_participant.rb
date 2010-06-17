require_dependency 'xgw/globals'

class HttpParticipant < Xgw::ParticipantBase
  consume(:fetch_directory_listing,
    :input => %w(remote_url),
    :optional_input => %w(http_username http_password),
    :sync => true
  ) do
    output = http_client(
      params.input[:remote_url],
      :http_username => params.input[:http_username],
      :http_password => params.input[:http_password]
    ).fetch(params.input[:remote_url])
    params.output.value = output
  end
  
  consume(:fetch_file,
    :input => %w(remote_url local_path),
    :optional_input => %w(http_username http_password),
    :sync => true
  ) do
    http_client(
      params.input[:remote_url],
      :http_username => params.input[:http_username],
      :http_password => params.input[:http_password]
    ).download(params.input[:remote_url], params.input[:local_path])
  end
  
  private
  
  def http_client(url, options)
    default_options = {}
    if Xgw::Globals.host_settings.verbose_http
      default_options[:debug] = true
    end
    options = default_options.update(options)
    ThreadLocalHttpClient.instance(options)
  end
end
