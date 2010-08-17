class HttpClient::SpawnWgetNetrc < HttpClient::SpawnWget
  include SpawnNetrcMixin
  
  private
  
  def build_command(*args)
    if @command.is_a?(Array)
      cmd = @command.dup
    else
      cmd = [@command]
    end
    unless @debug
      cmd << '-q'
    end
    cmd + args
  end
end
