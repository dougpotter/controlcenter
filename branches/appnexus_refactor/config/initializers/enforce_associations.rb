require 'enforce_associations'

ActiveRecord::Base.class_eval do
  include EnforceAssociations
end
