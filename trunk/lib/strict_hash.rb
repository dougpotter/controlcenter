module StrictHashMixin
  class KeyError < StandardError; end
  
  def [](key)
    if has_key?(key)
      super
    else
      raise KeyError, "Key does not exist in hash: #{key}"
    end
  end
end

class StrictHash < Hash
  include StrictHashMixin
end

class StrictHashWithIndifferentAccess < HashWithIndifferentAccess
  include StrictHashMixin
end
