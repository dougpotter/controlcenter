$: << File.dirname(File.expand_path(__FILE__))
require 'appnexus/connection'
require 'appnexus/request'
require 'appnexus/client'

module Appnexus
  def self.new
    Appnexus::Client.new
  end
end
