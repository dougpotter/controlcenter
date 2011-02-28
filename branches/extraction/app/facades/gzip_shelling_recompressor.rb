# This class allows shell command injection. Do not use in an environment
# with users (use GzipRecompressor instead).
class GzipShellingRecompressor
  # allowed options:
  # :gzip_path
  # :compression_level
  def initialize(options={})
    @gzip_path = options[:gzip_path] || 'gzip'
    if options[:compression_level]
      @compression_level = options[:compression_level].to_i
      if @compression_level == 0
        raise ArgumentError, "Invalid compression level #{options[:compression_level]}; try 1 through 9"
      end
    end
  end
  
  def transform(input_path, output_dir, output_filename_format)
    output_path = File.join(output_dir, output_filename_format % 1)
    
    if @compression_level
      compress_args = "-#{@compression_level}"
    else
      compress_args = ''
    end
    # shell command injection galore
    spawn_check("#{@gzip_path} -cd <#{input_path} |#{@gzip_path} #{compress_args} -c >#{output_path}")
    
    [output_path]
  end
end
