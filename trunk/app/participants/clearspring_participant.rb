class ClearspringParticipant < ParticipantBase
  consume :build_data_source_url, :input => %w(data_source data_source_path), :sync => true do
    data_source_path = params.input[:data_source_path]
    data_source = params.input[:data_source]
    url = "#{data_source_path}/#{data_source}/"
    params.output.value = url
  end
  
  consume(:filter_file_urls_by_date, :input => %w(file_urls data_source date), :sync => true) do
    data_source = params.input[:data_source]
    date = params.input[:date]
    prefix = "#{data_source}.#{date}"
    params.input[:file_urls].reject! do |file_url|
      File.basename(file_url)[0...prefix.length] != prefix
    end
  end
  
  consume :build_file_download_url, :sync => true do
    # launch file url downloads already builds urls,
    # nothing to do here
  end
  
  consume(:launch_file_url_downloads,
    :input => %w(file_urls download_root_dir data_source_path),
    :optional_input => %w(http_username http_password),
    :sync => true
  ) do
    jids = []
    params.input[:file_urls].each do |remote_url|
      remote_relative_path = figure_relative_path(params.input[:data_source_path], remote_url)
      local_path = File.join(params.input[:download_root_dir], remote_relative_path)
      job = RuoteGlobals.host.launch(:clearspring_file_download,
        params.input.merge(:remote_url => remote_url, :local_path => local_path))
      jids << job.rjid
    end
    params.output.value = jids
  end
  
  consume(:launch_split, :input => %w(local_path gzip_root_dir download_root_dir), :sync => true) do
    local_relative_path = figure_relative_path(params.input[:download_root_dir], params.input[:local_path])
    local_relative_path =~ /^(.*?)(\.log\.gz)?$/
    name, ext = $1, $2
    filename_format = "#{name.sub('%', '%%')}.%03d#{ext}"
    job = RuoteGlobals.host.launch(:clearspring_file_split,
      params.input.merge(
        :source_path => params.input[:local_path],
        :dest_dir => params.input[:gzip_root_dir],
        :dest_filename_format => filename_format
      ))
    params.output.value = job.rjid
  end
  
  consume(:launch_uploads, :input => %w(local_paths), :sync => true) do
    jids = []
    params.input[:local_paths].each do |path|
      job = RuoteGlobals.host.launch(:clearspring_file_upload,
        params.input.merge(:source_path => path))
      jids << job.rjid
    end
    params.output.value = jids
  end
  
  consume(:build_upload_path, :input => %w(data_source date clearspring_pid source_path), :sync => true) do
    filename = File.basename(params.input[:source_path])
    path = "#{params.input[:clearspring_pid]}/v2/raw-#{params.input[:data_source]}/#{params.input[:date]}/#{filename}"
    params.output.value = path
  end
  
  consume(:mkdir_download_dirname,
    :input => %w(data_source_path file_urls download_root_dir),
    :sync => true
  ) do
    params.input[:file_urls].each do |remote_url|
      remote_relative_path = figure_relative_path(params.input[:data_source_path], remote_url)
      local_path = File.join(params.input[:download_root_dir], remote_relative_path)
      FileUtils.mkdir_p(File.dirname(local_path))
    end
  end
  
  consume(:mkdir_split_dirname,
    :input => %w(local_path download_root_dir gzip_root_dir),
    :sync => true
  ) do
    download_relative_path = figure_relative_path(params.input[:download_root_dir], params.input[:local_path])
    gzip_path = File.join(params.input[:gzip_root_dir], download_relative_path)
    FileUtils.mkdir_p(File.dirname(gzip_path))
  end
  
  private
  
  def figure_relative_path(root, absolute_path)
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
end
