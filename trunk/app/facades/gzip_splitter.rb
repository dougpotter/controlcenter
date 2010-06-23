class GzipSplitter
  attr_accessor :header_pattern, :read_buffer_size, :debug, :verify
  
  # allowed options:
  # :header_pattern
  # :read_buffer_size
  # :debug -- print debugging messages to $stderr, can be very verbose!
  # :verify -- executes gzip -l and prints compression ratio, or error message
  def initialize(options={})
    # Defaults, see notes at end of file
    @header_pattern = options[:header_pattern] || "\037\213\b\000\000"
    @read_buffer_size = options[:read_buffer_size] || 4096
    @debug = options[:debug] || false
    @verify = options[:verify] || false
    
    @header_length = @header_pattern.length
  end

  def transform(input_path, output_dir, output_filename_format)
    infile = File.open(input_path, "rb")
    debug_print("Opened #{input_path}") if @debug
    output_file = nil
    
    byte_read_buffer = String.new
    #temp_read_buffer = String.new

    if @debug then 
      debug_print("read_buffer_size=#{@read_buffer_size}")
      debug_print("header_length=#{@header_length}")
    end

    begin
      index = 0
      output_path = File.join(output_dir, output_filename_format % index)
      output_file = File.new(output_path, 'wb')
      output_paths = [output_path]
      if @debug then debug_print("Writing to #{output_path}") end
      
      while !infile.eof?
        # changed to one line
        #temp_read_buffer = infile.read(@read_buffer_size)  
        #byte_read_buffer << temp_read_buffer
        byte_read_buffer << infile.read(@read_buffer_size) 
        
        pattern_idx = byte_read_buffer.index(@header_pattern)

        # Case 1
        # If pattern is at start of buffer, 
        # write buffer and continue
        # Assumption is that there is only one start of 
        # pattern in the buffer.
        if pattern_idx == 0 then
          write_byte_buffer(output_file, byte_read_buffer, true)
          byte_read_buffer = String.new
          next
        end

        # Case 2
        # Pattern not found in buffer and not at end of input file
        # write buffer and continue
        # Do not completely clear the buffer since start of 
        # pattern may be at end of buffer
        if !pattern_idx && !infile.eof? then
          slice_length = @read_buffer_size - @header_length - 1
          slice_data = byte_read_buffer.slice!(0..slice_length)
          write_byte_buffer(output_file, slice_data, false)
          next
        end

        # Case 3
        # Pattern found in middle of buffer
        # Slice buffer at position of pattern start
        # Write slice data to ouput file,
        # do not clear buffer remainder
        # Close output file
        # If input file not EOF, set new output filename 
        if pattern_idx && pattern_idx > 0 then
          mid_data = byte_read_buffer.slice!(0..pattern_idx-1)
          write_byte_buffer(output_file, mid_data, true)
          #byte_read_buffer = String.new
          if !infile.eof? then
            close_output_file(output_file, output_path)
            index += 1
            output_path = File.join(output_dir, output_filename_format % index)
            output_file = File.new(output_path, 'wb')
            output_paths << output_path
            if @debug then debug_print("Writing to #{output_path}") end
            next
          end
        end

        # Case 4
        # End of input file
        # Write whatever is left in buffer and close ouput file
        if infile.eof?
          write_byte_buffer(output_file, byte_read_buffer, true)
        end
      end
        
    ensure
      infile.close
      if @debug then debug_print("Closed #{input_path}") end
      p output_path
      if output_file
        close_output_file(output_file, output_path)
      end
    end
    
    output_paths
  end
  
  private
  
  def debug_print(msg)
    $stderr.puts(msg)
  end

  def write_byte_buffer(ofile, buff, clear)
    ofile.syswrite(buff)
    # buff.clear # doesn't exist in 1.8.6
    # useless code
    if clear then
      buff = nil
    end
  end

  def close_output_file(ofile, output_path)
    ofile.close
    if @debug then debug_print("Closed output_file=#{output_path}") end
    if @verify then
      d = `gzip -l #{output_path}`
      if @debug then debug_print("#{d}") end
      if d.match("ratio") then 
        pct = d.split("\n")[1].split(" ")[2].chop.to_f
        if pct > 49 && pct < 100 then
          debug_print("Success: #{output_path} compression=#{pct}%")
        else
          raise "Failure: #{output_path} compression=#{pct}%\n"
        end
      else
        raise "Failure: #{output_path} Invalid gzip -l output%\n"
      end
    end
  end
end

# Notes
#
# read_buffer_size = 4096 because somehow I think that is the default block size
# at least on research.
# This code will probably not work if set too low, like <= length of search pattern,
# or too high, like 1Mb+
#
# CS files, use this form (1f8b... etc, is
# the fixnum representation, for reference only)
#header_pattern = '1f8b80000'
# 
# Correct form for search pattern:
#header_pattern = "\037\213\b\000\000"
#
# This pattern will fail on large (250Mb+) CS files, it can be used
# to test the gzip verification function
#header_pattern = "\037\213\b"

# For test files, constructed with:
# cat 1.gz 2.gz 3.gz > test.gz
#header_pattern = '1f8b8'
#header_pattern = "\037\213\b"
#
