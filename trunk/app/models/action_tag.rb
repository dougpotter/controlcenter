class ActionTag < ActiveRecord::Base
  belongs_to :partner

  validates_presence_of :name, :sid, :url, :partner_id
  validates_uniqueness_of :sid
  validates_numericality_of :sid, :greater_than => 9999, :less_than => 100000

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
