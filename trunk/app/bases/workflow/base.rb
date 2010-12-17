module Workflow
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
    include Logger
    include DebugPrint
    include Locking
    include Persistence
    include ConditionalPersistence
    include ErrorHandling
    include ConfigurationRetrieval
    
    attr_reader :params
    
    class << self
      def expose_params(*keys)
        keys.each do |key|
          define_method(key) do
            params[key]
          end
        end
      end
    end
    
    def initialize(options={})
      initialize_logger(options)
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
        :ca_file => params[:ca_file],
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
      s3_client_class.new(:debug => @params[:debug], :logger => self.logger)
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
    
    def date_with_hour(options)
      str = options[:date].to_s
      if options[:hour]
        separator = options[:separator]
        str += sprintf('%s%02d00', separator, options[:hour])
      end
      str
    end
    
    # ------
    
    def list_data_source_files
      absolute_file_urls = list_all_data_source_files
      absolute_file_urls.reject { |url| !should_download_url?(url) }
    end
  end
end
