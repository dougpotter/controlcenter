module PaperclipConfiguration
  class << self
    attr_accessor :storage
    attr_accessor :path_prefix
    attr_accessor :path_suffix
    
    def build_options(subdir)
      options = case storage
      when :s3
        {
          :s3_credentials => "#{RAILS_ROOT}/config/aws.yml",
          :bucket => subdir,
          :path => path_suffix
        }
      else
        parts = [path_prefix, subdir, path_suffix].reject { |part| part.nil? }
        path = File.join(*parts)
        {
          :path => path
        }
      end
      if storage
        options[:storage] = storage
      end
      options
    end
  end
  
  self.storage = nil
  self.path_prefix = nil
  self.path_suffix = ":attachment/:id/:style/:filename"
end
