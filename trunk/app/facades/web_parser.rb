require 'nokogiri'

class WebParser
  def parse_apache_httpd_file_list(page_text)
    extract_links(page_text, '//td/a')
  end
  
  def parse_nginx_httpd_file_list(page_text)
    extract_links(page_text, '//a')
  end
  
  def parse_any_httpd_file_list(page_text)
    extract_links(page_text, '//a')
  end
  
  private
  
  def extract_links(page_text, anchor_xpath)
    doc = Nokogiri::HTML(page_text)
    links = []
    doc.xpath(anchor_xpath).each do |link|
      if link['href'] =~ /^\w/
        links << link['href']
      end
    end
    links
  end
end
