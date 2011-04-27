# Debugging class. Prints the values read from and written to an IO.
class IOPrinter
  def initialize(io)
    @io = io
  end
  
  class << self
    def hook_read_method(meth)
      eval <<-EOT
        define_method :#{meth} do |*args|
          puts "#{meth}"
          value = @io.#{meth}(*args)
          p value
          value
        end
      EOT
    end
    
    def hook_write_method(meth)
      eval <<-EOT
        define_method :#{meth} do |*args|
          puts "#{meth}"
          p args
          @io.#{meth}(*args)
        end
      EOT
    end
  end
  
  hook_read_method :read
  hook_read_method :sysread
  hook_read_method :readline
  hook_read_method :readlines
  
  hook_write_method :write
  hook_write_method :syswrite
  hook_write_method :writeline
  hook_write_method :writelines
  
  def method_missing(meth, *args, &block)
    @io.__send__(meth, *args, &block)
  end
end
