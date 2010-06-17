class GzipParticipant < Xgw::ParticipantBase
  consume(:split_file, :input => %w(source_path dest_dir dest_filename_format), :sync => true) do
    recompressor = GzipRecompressor.new
    dest_files = recompressor.transform(
      params.input[:source_path],
      params.input[:dest_dir],
      params.input[:dest_filename_format]
    )
    params.output.value = dest_files
  end
end
