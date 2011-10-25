require 'spec_helper'

describe RequestCondition do
  before(:all) do
    # find a request conditional audience
    for audience in Beacon.new.audiences
      if Beacon.new.request_conditions(audience["id"].is_a?(Array))
        @audience_id = audience["id"]
      end
    end
    if @audience_id.blank?
      raise "No request conditional audiences! Can't run tests for RequestCondition"
    end
  end

  before(:each) do
    @request_condition_id = 
      Beacon.new.new_request_condition(@audience_id, :request_url_regex => "/reg/")
  end

  after(:each) do
    remove_all_request_conditions(@audience_id)
  end

  def remove_all_request_conditions(audience_id)
    for req_cond in Beacon.new.request_conditions(audience_id)
      Beacon.new.delete_request_condition(audience_id, req_cond["id"])
    end
  end

  it "#destroy should remove this request condition" do
    req_cond = Beacon.new.request_condition(@audience_id, @request_condition_id)
    req_cond.beacon_id = @request_condition_id
    req_cond.audience_id = @audience_id
    RequestCondition.new(
      :beacon_id => @request_condition_id,
      :audience_id => @audience_id,
      :request_url_regex => req_cond["request_url_regex"],
      :referer_url_regex => req_cond["referer_url_regex"]
    ).destroy
    Beacon.new.request_condition(@audience_id, @request_condition_id).should ==
      "Request condition with id #{@request_condition_id} not found"
  end
end
