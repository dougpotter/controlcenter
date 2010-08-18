module HttpClient::SpawnMixin
  protected
  
  def get_output(url, cmd)
    Subprocess.get_output(cmd)
  end
  
  def spawn_check(url, cmd)
    Subprocess.spawn_check(cmd)
  end
end
