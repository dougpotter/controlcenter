module HttpClient::SpawnMixin
  protected
  
  def get_output(url, cmd)
    with_exception_mapping(url) do
      Subprocess.get_output(cmd)
    end
  end
  
  def spawn_check(url, cmd)
    with_exception_mapping(url) do
      Subprocess.spawn_check(cmd)
    end
  end
  
  def with_exception_mapping(url)
    # note that exception_map is private, thus we need to pass true in the
    # second argument
    if respond_to?(:exception_map, true)
      map_exceptions(exception_map, url) do
        yield
      end
    else
      yield
    end
  end
end
