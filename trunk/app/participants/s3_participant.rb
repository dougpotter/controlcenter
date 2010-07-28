class S3Participant < ParticipantBase
  # note that passing keys/passwords in command line or environment is insecure.
  # s3sync can read ~/.s3conf/s3config.yml where credentials should be stored.
  consume(:upload_file,
    :input => %w(local_path s3_bucket s3_path),
    :optional_input => %w(lock),
    :sync => true
  ) do
    lock_conditionally(params.input[:lock]) do
      local_path = params.input[:local_path]
      remote_path = "#{params.input[:s3_bucket]}:#{params.input[:s3_path]}"
      if RuoteConfiguration.verbose_s3
        debug_print("S3put: #{local_path} -> #{remote_path}")
      end
      S3Client.new.put_file(params.input[:s3_bucket], params.input[:s3_path], params.input[:local_path])
    end
  end
  
  private
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end
