module AppnexusSyncParameterGenerationHelper
  def valid_appnexus_sync_parameter_attributes
    {
      :s3_xguid_list_prefix => 'xg-dev-test:/path/to/files',
      :appnexus_segment_id => 'TEST',
      :instance_type => 'm1.small',
      :instance_count => 2,
    }
  end
end

module ActiveRecordErrorParsingHelper
  # returns true if error contains an unrecognized dimension code error on account
  # of code_at_init
  def contains_unrecognized_code_error?(error, code_at_init)
    !error.record.errors.select { |e| 
      e[1] == "was indeterminate at initialization because " + 
        "#{code_at_init} was unrecognized" 
    }.empty?
  end
end

module ViewHelperMethodHelper
  # returns a basic set of selection option
  def default_ofcfs_result
    "<option value=\"an option\"></option>"
  end
end
