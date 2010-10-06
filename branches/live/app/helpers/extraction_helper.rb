module ExtractionHelper
  def valid_statuses
    [
      DataProviderFile::DISCOVERED,
      DataProviderFile::EXTRACTING,
      DataProviderFile::EXTRACTED,
      DataProviderFile::VERIFIED,
      DataProviderFile::BOGUS,
    ]
  end
  
  def status_name(status)
    %w(None Discovered Extracting Extracted Verified Bogus)[status]
  end
  
  def status_to_css_class(status)
    %w(none discovered extracting extracted verified bogus)[status]
  end
end
