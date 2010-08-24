class HttpClient::SpawnWgetNetrc < HttpClient::SpawnWget
  include SpawnNetrcMixin
  
  private
  
  def build_command(*args)
    cmd = common_command_options
    cmd + args
  end
end
