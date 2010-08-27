require 'fileutils'

# netrc(5) man page: http://linux.die.net/man/5/netrc

module HttpClient::SpawnNetrcMixin
  protected
  
  def get_output(url, cmd)
    with_netrc(url) do |netrc_dir|
      with_exception_mapping(url) do
        Subprocess.get_output(cmd, :env => {'HOME' => netrc_dir})
      end
    end
  end
  
  def spawn_check(url, cmd)
    with_netrc(url) do |netrc_dir|
      with_exception_mapping(url) do
        Subprocess.spawn_check(cmd, :env => {'HOME' => netrc_dir})
      end
    end
  end
  
  # Creates a .netrc file in a temporary directory with
  # http username and password; yields the directory path;
  # removes the directory when yielded to block returns.
  def with_netrc(url)
    uri = URI.parse(url)
    mkdtemp do |tmp_dir|
      File.open(file_path = File.join(tmp_dir, '.netrc'), 'w') do |file|
        # for good measure
        FileUtils.chmod(0600, file_path)
        file << "machine #{uri.host} login #{@http_username} password #{@http_password}"
      end
      yield tmp_dir
    end
  end
  
  # Ruby has no mkdtemp implementation. There is a C extension which
  # adds this functionality, but instead of using an additional dependency
  # this is a solution I am happy with.
  def mkdtemp
    cmd = %w(/usr/bin/env mktemp -d)
    # order taken from python tempfile library
    tmpdir = ENV['TMPDIR'] || ENV['TEMP'] || ENV['TMP'] || '/tmp'
    template = "#{tmpdir}/xgcc_httpclient_netrc.XXXXXX"
    # be mindful of possible spaces in user's tmpdir specification
    cmd << template
    # we get a newline at the end of standard output
    dir = Subprocess.get_output(cmd).strip
    # going to trust that dir is only readable/writable by us
    begin
      yield dir
    ensure
      FileUtils.rm_rf(dir)
    end
  end
end
