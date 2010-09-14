require 'custom_validations'

ActiveRecord::Base.class_eval do
  include CustomValidations
end
