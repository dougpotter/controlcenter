module Xgw
  module Utils
    def to_options_hash(hash)
      options_hash = {}
      hash.each do |key, value|
        options_hash[key.to_sym] = value
      end
      options_hash
    end
    module_function :to_options_hash
  end
end
