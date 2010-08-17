module HttpClient::SpawnMixin
  protected
  
  def get_output(cmd)
    Subprocess.get_output(cmd)
  end
  
  def spawn_check(cmd)
    Subprocess.spawn_check(cmd)
  end
end
