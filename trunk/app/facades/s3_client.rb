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

class S3Client
  def initialize(options={})
    right_aws_options = {}
    right_aws_options[:server] = AwsConfiguration.s3_host if AwsConfiguration.s3_host
    right_aws_options[:port] = AwsConfiguration.s3_port if AwsConfiguration.s3_port
    right_aws_options[:protocol] = AwsConfiguration.s3_protocol if AwsConfiguration.s3_protocol
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
    
    @s3.store_object_and_verify(:bucket => bucket, :key => remote_path, :data => content, :md5 => md5)
  end
  
  private
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end
