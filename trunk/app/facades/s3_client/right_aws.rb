# right_aws' parts don't require their dependencies, so we either
# have to require 'right_aws' and accept all their bloat or manually
# require dependencies of components we're using here.
#
# Note: dependencies change based on code path taken.
# For example, uploading files into empty s3 bucket has different
# dependencies from overwriting existing files.
#
# Require the entire thing to avoid unforeseen breakage in production
# due to the note above.
require 'right_aws'
require 'digest/md5'

class S3Client::RightAws < S3Client::Base
  CHUNK_SIZE = 65536
  
  def initialize(options={})
    super(options)
    right_aws_options = {}
    if AwsConfiguration.s3_host
      right_aws_options[:server] = AwsConfiguration.s3_host
      right_aws_options[:no_subdomains] = true
    end
    right_aws_options[:port] = AwsConfiguration.s3_port if AwsConfiguration.s3_port
    right_aws_options[:protocol] = AwsConfiguration.s3_protocol if AwsConfiguration.s3_protocol
    Rightscale::HttpConnection.params[:ca_file] = AwsConfiguration.ca_file if AwsConfiguration.ca_file
    @s3 = RightAws::S3Interface.new(
      AwsConfiguration.access_key_id,
      AwsConfiguration.secret_access_key,
      right_aws_options
    )
    @debug = options[:debug]
  end
  
  def put_file(bucket, remote_path, local_path)
    File.open(local_path) do |f|
      md5 = Digest::MD5.new
      while chunk = f.read(CHUNK_SIZE)
        md5.update(chunk)
      end
      f.rewind
      md5 = md5.hexdigest
      
      if @debug
        debug_print "S3put #{local_path} -> #{bucket}:#{remote_path}"
      end
      
      map_exceptions(exception_map, "#{bucket}:#{remote_path}") do
        @s3.store_object_and_verify(:bucket => bucket, :key => remote_path, :data => f, :md5 => md5)
      end
    end
  end
  
  def list_bucket_items(bucket, prefix=nil)
    entries = list_bucket_entries(bucket, prefix)
    entries.map { |entry| create_item(entry) }
  end
  
  # optimization method
  def list_bucket_files(bucket, prefix=nil)
    entries = list_bucket_entries(bucket, prefix)
    entries.map { |entry| entry[:key] }
  end
  
  # prefix is a "directory" name
  def list_bucket_subdirs(bucket, prefix=nil)
    # prefix must end with delimiter (slash) for s3 to return correct results
    prefix = prefix + '/' if prefix && prefix[-1] != ?/
    entries = list_bucket_subentries(bucket, prefix, '/')
    # entries contain prefix; remove prefix for usability
    # entries also contain the delimiter at the end; remove that too
    prefix_length = if prefix
      prefix.length
    else
      0
    end
    entries.map! do |entry|
      entry[prefix_length..-2]
    end
    # note that amazon specifies that keys are listed in alphabetical order,
    # i.e. they come to us sorted
    entries
  end
  
  private
  
  def create_item(entry)
    if etag = entry[:e_tag]
      md5 = S3Client::Item.etag_to_md5(etag)
    else
      md5 = nil
    end
    options = {
      :key => entry[:key],
      :size => entry[:size],
      :md5 => md5,
      :last_modified => entry[:last_modified],
    }
    S3Client::Item.new(options)
  end
  
  def list_bucket_entries(bucket, prefix)
    all_entries = []
    # apparently prefix is required
    @s3.incrementally_list_bucket(bucket, :prefix => prefix) do |response|
      all_entries += response[:contents]
    end
    all_entries
  end
  
  def list_bucket_subentries(bucket, prefix, delimiter)
    all_subentries = []
    @s3.incrementally_list_bucket(bucket, :prefix => prefix, :delimiter => delimiter) do |response|
      all_subentries += response[:common_prefixes]
    end
    all_subentries
  end
  
  def exception_map
    mapper = lambda do |exc, url|
      if http_code = exc.http_code
        if (http_code = http_code.to_i) == 400
          code, message = exc.message.split(': ', 2)
          if code == 'RequestTimeout'
            if message.downcase.index('idle connections')
              # Keep-alive timeout:
              # RequestTimeout: Your socket connection to the server was not read from or written to within the timeout period. Idle connections will be closed.
              raise HttpClient::KeepAliveTimeout.new(
                exc.message,
                :code => http_code,
                :url => url
              )
            else
              raise HttpClient::NetworkTimeout.new(
                exc.message,
                :code => http_code,
                :url => url
              )
            end
          end
        end
        convert_and_raise(exc, HttpClient::HttpError, url, :code => exc.http_code)
      end
    end
    
    [
      [RightAws::AwsError, mapper],
    ]
  end
end
