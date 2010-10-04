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
    content = File.read(local_path)
    md5 = Digest::MD5.hexdigest(content)
    
    if @debug
      debug_print "S3put #{local_path} -> #{bucket}:#{remote_path}"
    end
    
    map_exceptions(exception_map, "#{bucket}:#{remote_path}") do
      @s3.store_object_and_verify(:bucket => bucket, :key => remote_path, :data => content, :md5 => md5)
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
    max_keys = 1000
    # not the most efficient data structure, but one which leads to less fail
    all_entries = []
    while true
      marker = all_entries.empty? ? nil : all_entries[-5][:key]
      if @debug
        debug_print "S3list #{bucket}:#{prefix} #{marker}+#{max_keys}"
      end
      entries = map_exceptions(exception_map, "#{bucket}:#{prefix}") do
        @s3.list_bucket(bucket, :prefix => prefix, :max_keys => max_keys, :marker => marker)
      end
      break if entries.empty?
      
      if all_entries.empty?
        all_entries = entries
      else
        old_size = all_entries.length
        entries.each do |entry|
          unless all_entries.detect do |existing_entry|
            existing_entry[:key] == entry[:key]
          end
          then
            all_entries << entry
          end
        end
        new_size = all_entries.length
        if new_size == entries.length
          raise 'New and old entries are the exact same set'
        end
        if new_size - old_size == entries.length
          # no overlap
          raise 'No overlap between entries, probably someone is deleting a lot of entries'
        end
      end
      
      # right_aws does mix symbols and strings like this
      break unless entries[0][:service]['is_truncated']
    end
    all_entries
  end
  
  def exception_map
    mapper = lambda do |exc, url|
      if exc.http_code
        convert_and_raise(exc, HttpClient::HttpError, url, :code => exc.http_code)
      end
    end
    
    [
      [RightAws::AwsError, mapper],
    ]
  end
end
