# Gzip recompressor/splitter interface.
class GzipTransformer
  # Optional constructor, must be callable without any arguments
  def initialize(options={})
  end
  
  # Takes gzip-compressed file at input_path, which is an
  # absolute path, and creates one or more gzip-compressed files
  # in output_dir, which is an absolute path as well.
  #
  # Each output file name should be generated from
  # output_filename_format by substituting the current file
  # number as follows:
  #
  #  output_filename = output_filename_format % file_number
  #
  # output_filename_format may include formatting instructions for
  # the file number, such as %d or %03d.
  #
  # output_filename_format may contain a relative path such as
  # 20100601/view-%02d.log.gz. In this case it is the caller's
  # responsibility to ensure that any required subdirectories
  # (20100601 in this example) exist prior to the call.
  #
  # Return value is an array of absolute paths of created files.
  def transform(input_path, output_dir, output_filename_format)
  end
end
