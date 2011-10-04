module Workflow
  module S3PathBuilding
    # ------ standard s3 output paths
    
    def build_s3_dirname_for_date(date)
      prefix = build_s3_prefix_for_channel
      "#{prefix}/#{date}"
    end
    
    def build_s3_dirname_for_params
      build_s3_dirname_for_date(params[:date])
    end
    
    def build_s3_dirname_for_path(path)
      prefix = build_s3_prefix_for_channel
      # XXX we could use basename here
      date = determine_name_date_from_data_provider_file(path)
      "#{prefix}/#{date}"
    end
  end
end
