module LazySass
  class << self
    attr_accessor :options
  end
  
  self.options = {}
  
  class << self
    def load!
      require 'sass/plugin'
      options.each do |key, value|
        ::Sass::Plugin.options[key] = value
      end
    end
  end
end
