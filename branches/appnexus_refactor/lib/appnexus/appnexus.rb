$: << File.dirname(File.expand_path(__FILE__))
require 'appnexus/configuration'
require 'appnexus/connection'
require 'appnexus/request'
require 'appnexus/client'

module Appnexus
  extend Configuration

  def self.new
    Appnexus::Client.new
  end
end
