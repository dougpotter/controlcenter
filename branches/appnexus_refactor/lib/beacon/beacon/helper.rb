class Hash
  def url_encode
    key_value_pairs = []
    self.each do |k,v|
      key_value_pairs << "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}"
    end
    return key_value_pairs.join("&")
  end
end
