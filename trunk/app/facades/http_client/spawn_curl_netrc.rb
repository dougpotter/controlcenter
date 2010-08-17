class HttpClient::SpawnCurlNetrc < HttpClient::SpawnCurl
  include SpawnNetrcMixin
  
  private
  
  def build_command(*args)
    if @command.is_a?(Array)
      cmd = @command.dup
    else
      cmd = [@command]
    end
    unless @debug
      cmd << '-s'
    end
    cmd + args
  end
end
