class ActionTag < ActiveRecord::Base
  belongs_to :partner

  validates_presence_of :name, :sid, :partner_id
  validates_uniqueness_of :sid
  validates_numericality_of :sid, :greater_than => 9999, :less_than => 100000

  before_validation :url_encode_name


  def url_encode_name
    self.name = CGI.escape(self.name) unless self.name.blank?
  end

  def pretty_name
    CGI.unescape(name)
  end

  def status
    "Active"
  end

  def secure_html
    "<img src=\"https://sxcdn.xgraph.net/#{partner.partner_code}/ai/xg.gif?"+
    "pid=#{partner.partner_code}&"+
    "sid=#{sid}&"+
    "type=ai&"+
      "pcid=#{name} "+
    "width=\"1\" height=\"1\" />"
  end

  def nonsecure_html
    "<img src=\"http://xcdn.xgraph.net/#{partner.partner_code}/ai/xg.gif?"+
    "pid=#{partner.partner_code}&"+
    "sid=#{sid}&"+
    "type=ai&"+
    "pcid=#{name} "+
    "width=\"1\" height=\"1\" />"
  end

  def js
    "<script type=\"text/javascript\">\n\n"+
    "var xgJsHost = ((\"https:\" == document.location.protocol) ?\n"+
    "\"https://sxcdn.\" : \"http://xcdn.\");\n\n"+
    "var refValue = \"\"; try {refValue = top.document.referrer;}\n"+
    "catch (xgErr) {refValue = \"\";}\n\n"+
    "document.write(unescape(\"%3Cimg\n"+
    "src='\"+xgJsHost+\"xgraph.net/#{partner.partner_code}/ai/xg.gif?\n"+
    "pid=#{partner.partner_code}&sid=#{sid}&pcid=#{pcid}&type=ai&ref=\")\n"+
    "+escape(refValue)+\"&dref=\"+escape(document.referrer)+unescape\n"+
    "(\"'%3E%3C/img%3E\"));\n\n"+
    "</script>"
  end

  def pcid
    name
  end

  class << self
    def generate_sid
      CodeGenerator.generate_unique_code(
        self,
        :sid,
        :length => 5,
        :alphabet => '1234567890',
        :transform => lambda { |code| code.to_i },
        :reject_if => lambda { |code| 
          code.to_s.length != 5 || 
          code <= 9999 ||  
          code >= 100000
        } 
      )   
    end 
  end
end
