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

module AppnexusClientHelper
  def remove_all_test_creatives_from_apn
    require 'curl'
    agent = AppnexusClient::API.new_agent

    test_advertiser = APN_CONFIG["test_codes"]["advertiser"]
    agent.url = Creative.apn_action_url(:index, test_advertiser)
    agent.http_get
    test_creatives = 
      ActiveSupport::JSON.decode(agent.body_str)["response"]["creatives"]
    test_creative_codes = test_creatives.map { |c| c["code"] }
    for creative_code in test_creative_codes
      agent.url = Creative.apn_action_url(
        :delete, 
        [ test_advertiser, creative_code ]
      )
      agent.http_delete
    end
  end
end
