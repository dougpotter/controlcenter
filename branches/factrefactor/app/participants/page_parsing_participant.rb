require 'nokogiri'

class PageParsingParticipant < ParticipantBase
  consume(:parse_apache_httpd_file_list,
    :input => %w(page_text),
    :sync => true
  ) do
    extract_links('//td/a')
  end
  
  consume(:parse_nginx_httpd_file_list,
    :input => %w(page_text),
    :sync => true
  ) do
    extract_links('//a')
  end
  
  private
  
  def extract_links(anchor_xpath)
    doc = Nokogiri::HTML(params.input[:page_text])
    links = []
    doc.xpath(anchor_xpath).each do |link|
      if link['href'] =~ /^\w/
        links << link['href']
      end
    end
    params.output.value = links
  end
end
