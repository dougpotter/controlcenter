module ActiveRecordExtensions
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end
  
  module Quoting
    # A shorter alias for quote_table_name
    def quote_identifier(name)
      connection.quote_table_name(name)
    end
  end

  module Errors
    def errors=(other_errors)
      self.errors.clear
      other_errors.each do |attr,msg|
        self.errors.add(attr, msg)
      end
    end
  end

  module ClassMethods
    include Quoting
  end
  
  module InstanceMethods
    include Quoting
    include Errors
    private :quote_identifier
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecordExtensions
end
