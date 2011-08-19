class ByteLineCounter
  attr_reader :byte_count
  
  def initialize
    @lf_count = 0
    @trailing_eol = false
    @byte_count = 0
  end
  
  def update(chunk)
    @byte_count += chunk.length
    @lf_count += chunk.count("\n")
    @trailing_eol = chunk[-1] == "\n"
  end
  
  def line_count
    if @byte_count > 0 && !@trailing_eol
      @lf_count + 1
    else
      @lf_count
    end
  end
end
