# == Schema Information
# Schema version: 20100816164408
#
# Table name: data_provider_files
#
#  id                       :integer(4)      not null, primary key
#  data_provider_channel_id :integer(4)      not null
#  url                      :string(255)     not null
#  status                   :integer(4)      not null
#

class DataProviderFile < ActiveRecord::Base
  belongs_to :data_provider_channel
  
  def initialize(options)
    default_options = {:status => 0}
    super(default_options.update(options))
  end
  
  validates_presence_of :url
  validates_uniqueness_of :url, :scope => :data_provider_channel_id
end
