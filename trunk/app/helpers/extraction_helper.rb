module ExtractionHelper
  def valid_extraction_statuses
    [
      DataProviderFile::DISCOVERED,
      DataProviderFile::EXTRACTING,
      DataProviderFile::EXTRACTED,
      DataProviderFile::VERIFIED,
      DataProviderFile::BOGUS,
    ]
  end
  
  def extraction_status_name(status)
    %w(None Discovered Extracting Extracted Verified Bogus)[status]
  end
  
  def extraction_status_to_css_class(status)
    %w(none discovered extracting extracted verified bogus)[status]
  end
end
