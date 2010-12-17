module S3AttachmentLogic

  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def has_s3_attachment attachment, bucket, path
      DelayedLoad.load_paperclip!

      has_attached_file attachment,
        PaperclipConfiguration.build_options(bucket)
    end
  end
end
