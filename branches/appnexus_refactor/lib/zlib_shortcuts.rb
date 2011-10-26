require 'zlib'
require 'stringio'

module ZlibShortcuts
  def gzip_compress(content)
    buffer = StringIO.new
    gz = Zlib::GzipWriter.new(buffer)
    gz << content
    gz.close
    buffer.string
  end
  module_function :gzip_compress
  
  def gzip_decompress(content)
    gz = Zlib::GzipReader.new(StringIO.new(content))
    content = gz.read
    gz.close
    content
  end
  module_function :gzip_decompress
end
