class GzipParticipant < ParticipantBase
  consume(:split_file, :input => %w(source_path dest_dir dest_filename_format), :sync => true) do
    # use recompressor or splitter
    #transformer = GzipRecompressor.new
    transformer = GzipSplitter.new
    dest_files = transformer.transform(
      params.input[:source_path],
      params.input[:dest_dir],
      params.input[:dest_filename_format]
    )
    params.output.value = dest_files
  end
end
