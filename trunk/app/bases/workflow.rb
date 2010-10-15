module Workflow
  # Base class for workflow errors
  class WorkflowError < StandardError; end
  
  # Another process had begun extracting the requested file.
  # Extraction may be actively proceeding, or the other process
  # may have died but its lock timeout had not yet passed.
  class FileExtractionInProgress < WorkflowError; end
  
  # The file had already been extracted with --once option.
  # This exception is only raised when --once option is given.
  # Without --once, it is possible to extract the same file
  # an arbitrary number of times.
  class FileAlreadyExtracted < WorkflowError; end
  
  # Raised when user requests a specific url to be downloaded
  # and provides date/hour/channel, and the url is actually not
  # in the specified date/hour/channel.
  class FileSpecMismatch < WorkflowError; end
  
  # Attempting to extract partially uploaded files.
  class FileNotReady < WorkflowError; end
  
  # Split verification was requested and failed
  class SplitVerificationFailed < WorkflowError; end
  
  class << self
    attr_accessor :default_logger
  end
  
  self.default_logger = Logger.new(STDOUT)
  
  module EntryPoints
    def run
      files = list_data_source_files
      # if :once option was given, #extract will raise a workflow error
      # for files that are being extracted elsewhere or that have been already extracted.
      # #run is called to do both discovery and extraction, and should extract all
      # extractable files. therefore we catch and ignore extraction in progress
      # and file already extracted workflow errors
      files.each do |file|
        begin
          extract(file)
        rescue Workflow::FileExtractionInProgress, Workflow::FileAlreadyExtracted
          # igrore
        end
      end
    end
    
    def discover
      list_data_source_files
    end
    
    def extract(file_url)
      perform_extraction(file_url)
    end
  end
  
  module Locking
    def self.included(base)
      base.class_eval do
        alias_method_chain :extract, :optional_locking
      end
    end
    
    def extract_with_optional_locking(file_url)
      if params[:lock]
        extract_with_locking(file_url)
      else
        extract_without_locking(file_url)
      end
    end
    
    def extract_with_locking(file_url)
      lock(file_url) do
        extract_without_locking(file_url)
      end
    end
    
    def extract_without_locking(file_url)
      perform_extraction(file_url)
    end
    
    def lock(remote_url)
      options = {
        :name => remote_url,
        :location => channel.data_provider.name,
        :capacity => 1,
        :timeout => 30.minutes,
        :wait => false,
        :create_resource => true,
      }
      
      if params[:debug]
        debug_callback = lambda do |message|
          debug_print "#{message} for #{remote_url}"
        end
        
        options[:debug_callback] = debug_callback
      end
      
      # ok_to_extract? needs to be in a critical section for each file,
      # otherwise two processes may check e.g. local caches simultaneously
      # and both decide to process the same file.
      #
      # yield is is the critical section because local caches are created
      # by extraction process. if we used special marker files then
      # extraction could be brought outside of the critical section.
      Semaphore::Arbitrator.instance.lock(options) do
        unless fully_uploaded?(remote_url)
          raise Workflow::FileNotReady, "File is not ready to be extracted: #{remote_url}"
        end
        if ok_to_extract?(remote_url)
          yield
        else
          if params[:debug]
            debug_print "File is already extracted: #{remote_url}"
          end
          raise Workflow::FileAlreadyExtracted, "File is already extracted: #{remote_url}"
        end
      end
    rescue Semaphore::ResourceBusy
      # someone else is processing the file, do nothing
      if params[:debug]
        debug_print "Lock is busy for #{remote_url}"
      end
      # raise the exception so that driver code can exit the process
      # with appropriate exit code
      raise Workflow::FileExtractionInProgress, "File is being extracted: #{remote_url}"
    end
  end
  
  module Persistence
    def create_data_provider_file(file_url)
      # Locked and lock-free runs should not be combined, since lock-free run may
      # overwrite data of the locked run and leave it in an inconsistent state
      # and the locked run would report success.
      #
      # Due to verification and also rerunning extraction however we must allow
      # updating status on existing files.
      
      DataProviderFile.transaction do
        file = channel.data_provider_files.find_by_url(file_url)
        if file
          if block_given?
            yield file
            file.save!
          end
        else
          begin
            file = DataProviderFile.new(
              :url => file_url,
              :data_provider_channel => channel
            )
            if block_given?
              yield file
            end
            file.save!
          rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid
            # see if someone else created the file concurrently
            file = channel.data_provider_files.find_by_url(file_url)
            unless file
              raise
            end
            # XXX what are the actual use cases that would generate conflicts?
            # what should we do in these cases?
            if block_given?
              yield file
            end
            file.save!
          end
        end
      end
    end
    
    module ErrorHandling
      # Required options:
      # :retry_count
      # :sleep_time
      # :exception_class or :exception_classes
      # Optional options:
      # :extra_callback
      def retry_errors(options)
        if options[:exception_class] && options[:exception_classes]
          raise ArgumentError, "Cannot specify both :exception_class and :exception_classes"
        end
        exception_classes = options[:exception_classes] || [options[:exception_class]]
        extra_callback = options[:extra_callback]
        0.upto(options[:retry_count]) do |index|
          begin
            return yield
          rescue Exception => e
            unless exception_classes.detect { |klass| e.is_a?(klass) }
              raise
            end
            if params[:debug]
              debug_print "Retrying after exception: #{e} (#{e.class}) at #{e.backtrace.first}"
            end
            
            if index == options[:retry_count]
              raise
            else
              if extra_callback
                extra_callback.call(e)
              end
              sleep(options[:sleep_time])
            end
          end
        end
      end
      
      def retry_network_errors(options)
        default_options = {:exception_class => HttpClient::NetworkError}
        retry_errors(default_options.update(options)) do
          yield
        end
      end
      
      def retry_aws_errors(options)
        callback = lambda do |exception|
          http_code = exception.http_code.to_i
          if http_code < 500 || http_code >= 600
            # only retry 5xx errors
            raise
          end
        end
        default_options = {:exception_class => S3Client::HttpError, :extra_callback => callback}
        retry_errors(default_options.update(options)) do
          yield
        end
      end
    end
    
    def note_data_provider_file_discovered(file_url)
      # discovered is the initial status. we never want to change status
      # from another status to discovered. here, only create a file object
      # if it does not already exist.
      DataProviderFile.transaction do
        file = channel.data_provider_files.find_by_url(file_url)
        if file
          if file.discovered_at.nil?
            file.discovered_at = Time.now
            file.save!
          end
        else
          file = DataProviderFile.create!(
            :url => file_url,
            :data_provider_channel => channel,
            :status => DataProviderFile::DISCOVERED,
            :discovered_at => Time.now
          )
        end
      end
    end
    
    def already_extracted?(source_url)
      file = channel.data_provider_files.find(:first,
        :conditions => [
          'data_provider_files.url=? and status not in (?)',
          source_url,
          [DataProviderFile::DISCOVERED, DataProviderFile::BOGUS]
        ]
      )
      return !file.nil?
    end
  end
  
  # In the Old Days, extraction processes were invoked with two basic
  # arguments: the data source (clearspring/akamai/etc.) and date.
  # The data source was given implicitly as the name of the script to run.
  # Extraction resolution was fixed to one day, and the default day was
  # yesterday.
  #
  # Current extraction processes take two additional arguments: hour and
  # channel. Data sources which are updated hourly may be extracted with
  # hourly granularity, allowing for the lag between data becoming available
  # and getting extracted to be reduced from ~2 days in the worst case to
  # several hours. Data sources which are divisible into meaningful disjoint
  # parts spatially expose multiple channels which may be extracted
  # concurrently, further reducing the lag between data availability and
  # extraction.
  #
  # Extraction process has two basic operations: discover and extract. The
  # discover operation lists files available in the data source and creates
  # data provider file objects in our database corresponding to found files.
  # The extract operation actually fetches the files (if necessary) and
  # uploads them to our permanent storage (s3). The separation allows for
  # extraction of individual files which were either missed or incorrectly
  # extracted on an earlier run and prevents losing track of files that existed
  # in the data source at some point but were deleted before they could be
  # extracted. A run shortcut is also provided which discovers and extracts all
  # discovered files.
  #
  # Extraction process for each data source has two complementary processes:
  # verification and cleanup. Verification process performs a separate pass
  # on extracted data and checks it against the data source with configurable
  # degree of strictness. It is intended to run a fair amount of time after
  # extraction completes to catch issues like files being made available
  # past our extraction lookback period, extracting files which are being
  # appended to, etc.
  #
  # Cleanup process removes old and/or temporary files created by other
  # procesess and/or the data source itself, in case of data source uploading
  # files to us (as opposed to us downloading files from data source).
  class Base
    include EntryPoints
    include Locking
    include Persistence
    include ErrorHandling
    
    attr_accessor :logger
    attr_reader :params
    
    def initialize(options={})
      @logger = options[:logger] || Workflow.default_logger
    end
    
    private
    
    def initialize_params(params)
      @params = params
      @network_error_retry_options = {:retry_count => 10, :sleep_time => 10}
      @update_process_status = params[:update_process_status]
    end
    
    def create_http_client(params)
      if params[:http_client]
        http_client_class = HttpClient.const_get(params[:http_client].camelize)
      else
        http_client_class = HttpClient::Curb
      end
      http_client_class.new(
        :http_username => params[:http_username],
        :http_password => params[:http_password],
        :timeout => params[:net_io_timeout],
        :debug => params[:debug],
        :logger => self.logger
      )
    end
    
    def create_s3_client(params)
      if params[:s3_client]
        s3_client_class = S3Client.const_get(params[:s3_client].camelize)
      else
        s3_client_class = S3Client::RightAws
      end
      s3_client_class.new(:debug => @params[:debug], :logger => @logger)
    end
    
    def with_process_status(options)
      if @update_process_status
        ProcessStatus.set(options) do
          yield
        end
      else
        yield
      end
    end
    
    def absolute_to_relative_path(root, absolute_path)
      root_len, abs_len = root.length, absolute_path.length
      if abs_len < root_len || absolute_path[0...root_len] != root
        raise ArgumentError, "Absolute path #{absolute_path} is not under #{root}"
      end
      relative_path = absolute_path[root_len...abs_len]
      if relative_path[0] == '/'
        relative_path = relative_path[1...relative_path.length]
      end
      relative_path
    end
    
    # ------
    
    def debug_print(msg)
      logger.debug(self.class.name) { msg }
    end
  end
  
  # Contains methods common to extract workflows.
  class ExtractBase < Base
    def channel
      params[:channel]
    end
    
    def date
      params[:date]
    end
    
    def hour
      params[:hour]
    end
    
    def s3_bucket
      params[:s3_bucket]
    end
    
    private
    
    # Record source urls as discovered if :record option was given to workflow.
    def possibly_record_source_urls_discovered(urls)
      if params[:record]
        urls.each do |url|
          note_data_provider_file_discovered(url)
        end
      end
    end
    
    # Record source url as extracted if :once option was given to workflow.
    def possibly_record_source_url_extracted(url)
      # See the comment in create_data_provider_file regarding mixing locked
      # and non-locked runs. Status files are only created for once runs
      # (which are also locked).
      if params[:once]
        create_data_provider_file(url) do |file|
          file.status = DataProviderFile::EXTRACTED
          file.extracted_at = Time.now.utc
        end
      end
    end
    
    # returns true if remote_url is not currently being extracted,
    # and had not been successfully extracted in the past.
    def ok_to_extract?(remote_url)
      if params[:once] and already_extracted?(remote_url)
        false
      else
        true
      end
    end
    
    # -----
    
    def validate_source_url_for_extraction!(url)
      unless should_download_url?(url)
        raise Workflow::FileSpecMismatch, "Url does not match download parameters: #{url}"
      end
    end
    
    # -----
    
    # Unlike downloading, uploading is common to all data sources.
    # As of this writing.
    def upload(local_path, s3_bucket, s3_path)
      with_process_status(:action => "uploading #{File.basename(local_path)}") do
        retry_network_errors(@network_error_retry_options) do
          retry_aws_errors(@network_error_retry_options) do
            @s3_client.put_file(s3_bucket, s3_path, local_path)
          end
        end
      end
    end
  end
  
  class Configuration
    # Returns parameters from configuration file.
    #
    # Allowed options:
    #
    # :config_path
    def initialize(options={})
      config_path = options[:config_path]
      unless config_path
        raise ArgumentError, ':config_path is required'
      end
      @config_params = YamlConfiguration.load(config_path)
      postprocess_params
    end
    
    def dup
      new = super
      new.instance_variable_set('@config_params', @config_params.dup)
      new
    end
    
    def update(options)
      options.each do |key, value|
        unless value.nil?
          @config_params[key] = value
        end
      end
      postprocess_params
      self
    end
    
    def merge(options)
      dup.update(options)
    end
    
    def to_hash
      # typically users expect to_* methods to return copies of data
      @config_params.dup
    end
    
    private
    
    # XXX consider refactoring this
    def postprocess_params
      if path = @config_params[:debug_output_path]
        # will also modify the hash
        path.gsub!(/:timestamp\b/, Time.now.strftime('%Y%m%d-%H%M%S'))
      end
      if @config_params[:once]
        @config_params[:lock] = true
      end
      if @config_params[:check_sizes_strictly] || @config_params[:check_sizes_exactly]
        @config_params[:check_sizes] = true
      end
    end
  end
end
