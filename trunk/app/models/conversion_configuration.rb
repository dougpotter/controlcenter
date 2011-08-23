class ConversionConfiguration < ActiveRecord::Base
  belongs_to :partner
  belongs_to :audience_source

  validates_presence_of :conversion_configuration_code, :name, :partner_id, :audience_source_id
  validates_numericality_of :partner_id, :audience_source_id
  validates_uniqueness_of :conversion_configuration_code

  def request_regex
    audience_source.request_regex if audience_source
  end

  def referer_regex
    audience_source.referrer_regex if audience_source
  end

  class << self
    def generate_conversion_configuration_code
      CodeGenerator.generate_unique_code(
        self,
        :conversion_configuration_code,
        :length => 4,
        :alphabet => '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        :transform => lambda { |code| code.to_i },
        :reject_if => lambda { |code| code.to_s.length != 4 } 
      )   
    end 
  end 

end
