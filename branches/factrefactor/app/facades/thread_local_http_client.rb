class ThreadLocalHttpClient
  class << self
    def instance(options={})
      instance = Thread.current[:http_client]
      unless instance
        instance = HttpClient.new(options)
        Thread.current[:http_client] = instance
      end
      instance
    end
  end
end
