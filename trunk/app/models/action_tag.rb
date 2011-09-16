class ActionTag < ActiveRecord::Base
  belongs_to :partner

  validates_presence_of :name, :sid, :url, :partner_id
  validates_uniqueness_of :sid
  validates_numericality_of :sid, :greater_than => 9999, :less_than => 100000

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
