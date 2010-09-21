# == Schema Information
# Schema version: 20100819181021
#
# Table name: data_provider_files
#
#  id                       :integer(4)      not null, primary key
#  data_provider_channel_id :integer(4)      not null
#  url                      :string(255)     not null
#  status                   :integer(4)      not null
#

class DataProviderFile < ActiveRecord::Base
  # a file object created for discovered files starts off in discovered
  # status
  DISCOVERED = 1
  # when a file extraction begins, its corresponding file object's status
  # is changed to extracting
  EXTRACTING = 2
  # when extraction is complete, status is set to extracted
  EXTRACTED = 3
  # when a separate process verifies file after extraction, the file
  # object's status is set to verified
  VERIFIED = 4
  # a file object in verified status that subsequently fails verification is
  # set to bogus status
  BOGUS = 5
  
  belongs_to :data_provider_channel
  
  def initialize(options)
    default_options = {:status => 0}
    super(default_options.update(options))
  end
  
  validates_presence_of :url
  validates_uniqueness_of :url, :scope => :data_provider_channel_id
end
