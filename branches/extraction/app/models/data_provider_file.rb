# == Schema Information
# Schema version: 20101220202022
#
# Table name: data_provider_files
#
#  id                       :integer(4)      not null, primary key
#  data_provider_channel_id :integer(4)      not null
#  url                      :string(255)     not null
#  status                   :integer(4)      not null
#  discovered_at            :datetime
#  extracted_at             :datetime
#  verified_at              :datetime
#  label_date               :date
#  label_hour               :integer(4)
#

# Label date and hour are used in extraction phase.
#
# Every discovered data provider file is marked with a date and singular hour.
# It is possible for files to be uploaded/made available a significant time
# after their labeled time and/or the timestamp of their most recent content
# entry. Such files are extracted by separate delayed extraction processes,
# and these processes identify whether a file is of appropriate age for them
# to handle it by looking at label date and hour.
#
# Some data providers include a time range in file name; others provide a
# single time which may conceivably be in the beginning, end or middle of
# the range. Our label date/hour should be consistent from one data provider
# to another and represent the temporal coordinate of the file relative to
# other files in the same data provider. It is important to meaningfully
# group files by date since extraction has a concept of date and is invoked
# for a particular date when catch-up extraction is performed.
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
