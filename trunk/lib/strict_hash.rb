module StrictHashMixin
  class KeyError < StandardError; end
  
  def [](key)
    if has_key?(key)
      super
    else
      if @optional_keys && @optional_keys[key]
        nil
      else
        raise KeyError, "Key does not exist in hash: #{key}"
      end
    end
  end
  
  def optional_keys(*keys)
    # same type of access (normal/indifferent) as main hash
    @optional_keys ||= self.class.new
    keys.each do |key|
      @optional_keys[key] = true
    end
  end
end

class StrictHash < Hash
  include StrictHashMixin
end

class StrictHashWithIndifferentAccess < HashWithIndifferentAccess
  include StrictHashMixin
end
