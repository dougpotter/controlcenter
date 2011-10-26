class HttpClient::SpawnCurlNetrc < HttpClient::SpawnCurl
  include SpawnNetrcMixin
  
  private
  
  def build_command(*args)
    cmd = common_command_options
    cmd << '-n'
    cmd + args
  end
end
