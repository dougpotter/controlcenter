require "nokogiri"
require "open-uri"
print "START\n"

# this gets me some output:
#doc = Nokogiri::HTML(open('http://slashdot.org'))
#doc.xpath('//h2').each do |td|
#  print "content=" + td.content
#end

# this returns almost nothing:
#puts open('http://ec2-75-101-189-1.compute-1.amazonaws.com:9100/jobtracker.jsp').read
# this returns the full document:
#puts open('http://ec2-75-101-189-1.compute-1.amazonaws.com:9100/jobtracker.jsp', 'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.2; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0)').read

v = open('http://ec2-75-101-189-1.compute-1.amazonaws.com:9100/jobtracker.jsp', 'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.2; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0)').read
#print v
doc = Nokogiri::HTML(v)
doc.xpath('//table/tr/td').each do |td|
#  if td.content == 'Running Jobs'
    print "TD=" + td.content + "\n"
#  end
end
print "\nEND\n"


