module S3AttachmentLogic

  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    require 'paperclip'

    def has_s3_attachment attachment, bucket, path
      has_attached_file attachment,
        :storage => :s3,
        :s3_credentials => "#{RAILS_ROOT}/config/aws.yml",
        :bucket => bucket, 
        :path => path
    end
  end
end