$: << File.dirname(File.expand_path(__FILE__))
require 'beacon/api'
require 'beacon/client'
require 'beacon/configuration'
require 'beacon/request'

module Beacon
  extend Configuration

  def hi
    puts "HI"
  end

  class << self
    # Alias for Beacon::Client.new
    #
    # @return [Beacon::Client]
    def new(options = {})
      Beacon::Client.new(options)
    end
  end
end
