$stdin.each_line do |line|
  m = /pid=([^\&]+)\&cid=([^\&]+)\&crid=([^\&]+)\&/.match(line)
  pid, cid, crid = m[1], m[2], m[3]
  
  $stdout.puts "{"
  $stdout.puts "  :creative_size_id => CreativeSize.find_by_height(#{/^([0-9]+)/.match(crid)[1]}),"
  $stdout.puts "  :campaign_id => Campaign.find_by_campaign_code(\"#{cid}\").id,"
  $stdout.puts "  :creative_code => \"#{crid}\""
  $stdout.puts "},"
end
