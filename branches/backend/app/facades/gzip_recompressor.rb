class GzipRecompressor
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
    
    input_file = output_file = nil
    pipe_rd = pipe_wr = de_rd = de_wr = ce_rd = ce_wr = nil
    cpid = dpid = nil
    
    begin
      # open files before forking to get exceptions in main process
      input_file = File.open(input_path, 'rb')
      output_file = File.open(output_path, 'wb')
      
      pipe_rd, pipe_wr = IO.pipe
      
      de_rd, de_wr = IO.pipe
      dpid = fork do
        # decompressor
        $stdin.reopen(input_file)
        $stdout.reopen(pipe_wr)
        de_rd.close
        $stderr.reopen(de_wr)
        pipe_rd.close
        pipe_wr.close
        exec(@gzip_path, '-cd')
      end
      
      ce_rd, ce_wr = IO.pipe
      cpid = fork do
        # compressor
        $stdin.reopen(pipe_rd)
        $stdout.reopen(output_file)
        ce_rd.close
        $stderr.reopen(ce_wr)
        pipe_rd.close
        pipe_wr.close
        args = [@gzip_path, '-c']
        if @compression_level
          args << "-#{@compression_level}"
        end
        exec(*args)
      end
      
      %w(pipe_rd pipe_wr de_wr ce_wr).each do |fd|
        eval <<-CODE
          #{fd}.close
          #{fd} = nil
        CODE
      end
      
      pid, dstatus = Process.wait2(dpid)
      dpid = nil
      pid, cstatus = Process.wait2(cpid)
      cpid = nil
      
      if dstatus != 0 || cstatus != 0
        %w(d c).each do |part|
          eval <<-CODE
            if #{part}status != 0
              msg = #{part}e_rd.read
              if !msg.empty?
                msg = ": \#{msg}"
              end
              msg = #{part}msg = "#{part == 'c' ? 'C' : 'Dec'}ompression failed: exit code \#{#{part}status}\#{msg}"
            end
          CODE
        end
        if dstatus != 0 && cstatus != 0
          msg = "#{dmsg}\n#{cmsd}"
        end
        raise CommandFailed, msg
      end
    ensure
      %w(pipe_rd pipe_wr de_wr ce_wr).each do |fd|
        eval <<-CODE
          if #{fd}
            #{fd}.close rescue nil
          end
        CODE
      end
      de_rd.close if de_rd
      ce_rd.close if ce_rd
      if dpid
        Process.wait(dpid) rescue nil
      end
      if cpid
        Process.wait(cpid) rescue nil
      end
      if input_file
        input_file.close rescue nil
      end
      if output_file
        output_file.close rescue nil
      end
    end
    
    [output_path]
  end
end
