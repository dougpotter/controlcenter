require 's3_attachment_logic'

ActiveRecord::Base.class_eval do
  include S3AttachmentLogic
end
