module ExtractionHelper
  def status_to_css_class(status)
    %w(none discovered extracting extracted verified bogus)[status]
  end
end
