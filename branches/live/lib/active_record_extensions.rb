module ActiveRecordExtensions
  def self.included(base)
    base.class_eval do
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    # A shorter alias for quote_table_name
    def quote_identifier(name)
      connection.quote_table_name(name)
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecordExtensions
end
