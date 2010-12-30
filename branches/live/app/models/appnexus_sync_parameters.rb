# == Schema Information
# Schema version: 20101220202022
#
# Table name: appnexus_sync_parameters
#
#  partner_code         :string
#  audience_code        :string
#  s3_xguid_list_prefix :string
#  appnexus_segment_id  :string
#  lookup_start_date    :string
#  lookup_end_date      :string
#  instance_type        :string
#  instance_count       :integer
#

class AppnexusSyncParameters < ActiveRecord::Base
  has_no_table
  
  # currently unused
  column :partner_code, :string
  column :audience_code, :string
  
  column :s3_xguid_list_prefix, :string
  validates_presence_of :s3_xguid_list_prefix
  # subdir/filename
  validates_format_of :s3_xguid_list_prefix, :with => %r(\A[a-zA-Z0-9\-]+:[a-zA-Z0-9\-_./]+/[a-zA-Z0-9\-_.]+\Z)
  
  column :appnexus_segment_id, :string
  validates_presence_of :appnexus_segment_id
  
  column :lookup_start_date, :string
  validates_format_of :lookup_start_date, :with => %r(\A\Z|\A\d{8}\Z), :allow_nil => true
  
  column :lookup_end_date, :string
  validates_format_of :lookup_end_date, :with => %r(\A\Z|\A\d{8}\Z), :allow_nil => true
  
  column :instance_type, :string
  validates_presence_of :instance_type
  validates_format_of :instance_type, :with => %r(\A[a-z]+\d\.[a-z]+\Z)
  
  column :instance_count, :integer
  validates_presence_of :instance_count
  validates_numericality_of :instance_count
  
  def initialize(options={})
    default_options = {:instance_type => 'm1.large', :instance_count => 2}
    super(default_options.update(options))
  end
end
