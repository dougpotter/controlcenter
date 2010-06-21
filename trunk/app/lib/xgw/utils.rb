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
    
    def to_string_hash(hash)
      new_hash = Hash.new
      hash.each do |key, value|
        new_hash[key.to_s] = value
      end
      new_hash
    end
    module_function :to_string_hash
  end
end
