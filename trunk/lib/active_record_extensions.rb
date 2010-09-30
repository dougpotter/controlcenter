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
  
  module ClassMethods
    include Quoting
  end
  
  module InstanceMethods
    include Quoting
    private :quote_identifier
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecordExtensions
end
