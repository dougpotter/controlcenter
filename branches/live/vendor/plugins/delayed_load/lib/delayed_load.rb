# DelayedLoad - cleanly delay loading of libraries,
#
# Please see README.rdoc for usage including important caveats.
module DelayedLoad
  extend self
  
  @@registry = {}
  @@initializers = {}
  
  def create(name)
    define_method("load_#{name}!") do
      return if @@registry[name]
      # delete initializers from hash to free up some memory
      initializers = @@initializers.delete(name)
      initializers.each do |block|
        block.call
      end
      @@registry[name] = true
    end
    @@initializers[name] = []
    if block_given?
      configure(name) do
        yield
      end
    end
  end
  
  def configure(name, &block)
    @@initializers[name] << block
  end
end
