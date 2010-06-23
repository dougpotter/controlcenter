class GzipSplitter

  attr_accessor :input_file, :header_pattern, :read_buffer_size,
    :output_path, :debug, :verify

  # Required initialization parameters
  # input_file
  #
  # Optional parameters to override defaults
  # header_pattern
  # read_buffer_size
  # output_path
  # debug -- print debugging messages to $stderr, can be very verbose!
  # verify -- executes gzip -l and prints compression ratio, or error message
  def initialize(input_file, params)

    # Defaults, see notes at end of file
    @header_pattern = "\037\213\b\000\000"
    @read_buffer_size = 4096

    if input_file then
      @input_file = input_file
    else
      raise = "input_file name not supplied"
    end
    if params[:header_pattern] then
      @header_pattern = params[:header_pattern]
    end
    if params[:read_buffer_size] then
      @read_buffer_size = params[:read_buffer_size]
    end
    if params[:output_path] then
      @output_path = params[:output_path]
    end if
    if params[:debug] then
      @debug = params[:debug]
    end
    if params[:verify] then
      @verify = params[:verify]
    end
    @header_length = @header_pattern.length
    @output_file_root = @input_file.split(/.log.gz/)[0]
    @output_file_part = 0
    @output_filename = ""
    @output_filename_paths = Array.new
  end

  def debug_print(msg)
    $stderr.puts(msg)
  end

  def set_output_filename()
    # this function does absolutely no checking
    # on output_path, except to chomp and put pack trailing /
    @output_file_part = @output_file_part + 1
    fpart = sprintf("%03d", @output_file_part)
    @output_filename = "#{@output_file_root}.#{fpart}.log.gz"
    if @output_path then
      @output_path.chomp!("/")
      @output_filename = "#{@output_path}/#{@output_filename}"
    end
    if @debug then
      debug_print("@output_filename=#{@output_filename}")
    end
  end

  def write_byte_buffer(ofile, buff, clear)
    ofile.syswrite(buff)
    # buff.clear # doesn't exist in 1.8.6
    if clear then
      buff = nil
    end
  end

  def close_output_file(ofile)
    ofile.close
    if @debug then debug_print("Closed output_file=#{@output_filename}") end
    if @verify then
      d = `gzip -l #{@output_filename}`
      if @debug then debug_print("#{d}") end
      if d.match("ratio") then 
        pct = d.split("\n")[1].split(" ")[2].chop.to_f
        if pct > 49 && pct < 100 then
          debug_print("Success: #{@output_filename} compression=#{pct}%")
        else
          raise "Failure: #{@output_filename} compression=#{pct}%\n"
        end
      else
        raise "Failure: #{@output_filename} Invalid gzip -l output%\n"
      end
    end
    @output_filename_paths.push(@output_filename)
  end

  def split_file
    output_file = "nofile"

    if File.exist?(@input_file) then
      infile = File.open(@input_file, "rb")
      debug_print("Opened #{@input_file}")
    else
      raise "input_file #{@input_file} not found"
    end

    @byte_read_buffer = String.new
    @temp_read_buffer = String.new

    if @debug then 
      debug_print("read_buffer_size=#{@read_buffer_size}")
      debug_print("header_length=#{@header_length}")
    end

    set_output_filename

    while !infile.eof? 
      if !File.exist?(output_file)
        output_file = File.new(@output_filename, "wb")
      end

      # changed to one line
      #@temp_read_buffer = infile.read(@read_buffer_size)  
      #@byte_read_buffer << @temp_read_buffer
      @byte_read_buffer << infile.read(@read_buffer_size) 
      
      pattern_idx = @byte_read_buffer.index(@header_pattern)

      # Case 1
      # If pattern is at start of buffer, 
      # write buffer and continue
      # Assumption is that there is only one start of 
      # pattern in the buffer.
      if pattern_idx && pattern_idx == 0 then
        write_byte_buffer(output_file, @byte_read_buffer, true)
        @byte_read_buffer = String.new
        next
      end

      # Case 2
      # Pattern not found in buffer and not at end of input file
      # write buffer and continue
      # Do not completely clear the buffer since start of 
      # pattern may be at end of buffer
      if !pattern_idx && !infile.eof? then
        slice_length = @read_buffer_size - @header_length - 1
        slice_data = @byte_read_buffer.slice!(0..slice_length)
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
        mid_data = @byte_read_buffer.slice!(0..pattern_idx-1)
        write_byte_buffer(output_file, mid_data, true)
        #@byte_read_buffer = String.new
        close_output_file(output_file)
        if !infile.eof? then
          set_output_filename
          output_file = File.new(@output_filename, "wb")
          next
        end
      end

      # Case 4
      # End of input file
      # Write whatever is left in buffer and close ouput file
      if infile.eof?
        write_byte_buffer(output_file, @byte_read_buffer, true)
        close_output_file(output_file)  
      end
    end	

    infile.close
    if @debug then debug_print("Closed #{@input_file}") end

    @output_filename_paths
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
