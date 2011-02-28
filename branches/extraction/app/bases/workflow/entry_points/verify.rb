module Workflow
  module EntryPoints
    module Verify
      def check_listing
        data_source_urls = list_data_source_files
        our_paths = list_bucket_files
        have, missing, partial = check_correspondence(data_source_urls, our_paths)
        report_correspondence(have, missing, partial)
        missing.empty? && partial.empty?
      end
      
      def check_consistency
        data_source_urls = list_data_source_files
        have, missing = check_existence(data_source_urls)
        report_existence(have, missing)
        ok = missing.empty?
        
        our_paths = list_bucket_files
        have, missing, partial = check_correspondence(data_source_urls, our_paths)
        report_correspondence(have, missing, partial)
        ok && missing.empty? && partial.empty?
      end
      
      def check_our_existence
        have, missing = find_our_files
        report_existence(have, missing)
        missing.empty?
      end
      
      def check_their_existence
        have, missing = find_their_files
        report_existence(have, missing)
        missing.empty?
      end
    end
  end
end
