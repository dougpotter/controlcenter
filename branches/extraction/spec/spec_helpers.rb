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
