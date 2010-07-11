class HttpParticipant < ParticipantBase
  consume(:fetch_directory_listing,
    :input => %w(remote_url),
    :optional_input => %w(http_username http_password lock),
    :sync => true
  ) do
    if lock_name = params.input[:lock]
      lock(lock_name) do
        fetch_directory_listing
      end
    else
      fetch_directory_listing
    end
  end
  
  consume(:fetch_file,
    :input => %w(remote_url local_path),
    :optional_input => %w(http_username http_password lock),
    :sync => true
  ) do
    if lock_name = params.input[:lock]
      lock(lock_name) do
        fetch_file
      end
    else
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
  
  def lock(lock_name)
    location = Socket.gethostname
    # todo: make configurable
    capacity = 1
    allocation = nil
    1.upto(101) do |index|
      begin
        allocation = Semaphore::Arbitrator.instance.acquire(
          lock_name, :location => location, :timeout => 30.minutes
        )
        break
      rescue Semaphore::ResourceNotFound
        # we're missing the resource.
        # since every host uses their own resource, first time
        # we run something on a newly provisioned box the resource
        # is expected to be missing.
        # create it accounting for other threads racing to
        # do the same.
        resource = Semaphore::Resource.new(:name => lock_name, :location => location, :capacity => capacity)
        begin
          resource.save!
        rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid
          # see if it already exists
          if Semaphore::Resource.identity(lock_name, location)
            break
          else
            raise
          end
        end
      rescue Semaphore::ResourceBusy
        if index == 100
          raise
        else
          # wait
          sleep 5
        end
      end
    end
    
    begin
      yield
    ensure
      Semaphore::Arbitrator.instance.release(allocation)
    end
  end
end
