require 'spec_helper'

describe Beacon do
  before(:all) do
    @b = Beacon.new
    @api_root = BEACON_CONFIG[:api_root_url]
    @agent = Curl::Easy.new

    seed_beacon
  end

  def audiences_in_order
    Hashie::Mash.new(JSON.parse(
      Curl::Easy.http_get(@api_root + "audiences").body_str
    )).audiences.sort { |x,y| x.id <=> y.id }
  end

  def by_id
    return Proc.new { |x,y| x.id <=> y.id }
  end

  def last_audience_id
    audiences_in_order.last.id
  end

  def audience_id_with_sync_rules
    for audience in audiences_in_order
      if sync_rules(audience.id)
        return audience.id
      end
    end
    raise "No audience has sync rules"
  end

  def sync_rules(audience_id)
    c = Curl::Easy.new(
      @api_root + "audiences/NUM/sync_rules".
      gsub("NUM", "#{audience_id}"))
    c.http_get
    Hashie::Mash.new(JSON.parse(c.body_str)).sync_rules
  end

  def sync_rule_id
    sync_rules(audience_id_with_sync_rules).sort(&by_id).first.id
  end

  def audience_id_with_request_condition
    for audience in audiences_in_order
      if audience["type"] == 'request-conditional' && 
        !request_conditions(audience.id).blank?
        return audience.id
      end
    end
    raise "No audience has request conditions"
  end

  def request_conditions(audience_id)
    @agent = Curl::Easy.new(
      @api_root + "audiences/#{audience_id}/request_conditions")
    @agent.http_get
    Hashie::Mash.new(JSON.parse(@agent.body_str)).request_conditions
  end

  ## Audience 
  context "audience admin" do
    it "#audiences should return a hash of all audiences" do
      beacon_response = @b.audiences.audiences.sort { |x,y| x.id <=> y.id }
      beacon_response == audiences_in_order
    end

    it "#audience(#) should return the audience with id of #" do
      correct_audience = 
        Hashie::Mash.new(JSON.parse(Curl::Easy.http_get(
          @api_root + "audiences/19"
      ).body_str))
      @b.audience(19).should == correct_audience
    end

    it "#new_audience with hash of legal params should create a new audience" do
      last_id = audiences_in_order.last.id
      @b.new_audience({
        :name => "a new audience", :audience_type => "global"
      })
      @b.audiences.audiences.sort { |x,y| x.id <=> y.id }.last.id.should ==
        last_id + 1
    end

    it "#new_audience should return error message with illegal attribute name" do
      @b.new_audience({
        :name => "a new audience", :type => "global"
      }).should == "Invalid value for audience type: null"
    end

    it "#new_audience should return error message with blank hash as argument" do
      @b.new_audience({}).should == "Audience name was not given"
    end

    it "#new_audience should return beacon ID of new audience" do
      last_id = audiences_in_order.last.id.to_i
      return_value = @b.new_audience({
        :name => "a new audience", :audience_type => "global"
      })
      return_value.should == (last_id + 1).to_s
    end

    it "#update_audience should update the audience" do
      @b.new_audience(
        :name => "michael", :audience_type => "global"
      )
      @b.update_audience(audiences_in_order.last.id, "Mog", "false")
      @b.audience(audiences_in_order.last.id).name.should == "Mog"
    end
  end


  ## Sync Rules
  context "sync rules admin" do
    

    it "#sync_rules(audience_id) should return all the sync rules for the"+
    " audience" do
      audience_id = audience_id_with_sync_rules
      rules_in_order = sync_rules(audience_id).sort(&by_id)
      @b.sync_rules(audience_id).sync_rules.sort(&by_id).should == rules_in_order
    end

    it "#new_sync_rule with all legal arguments should return id of new sync rule" do
      id = @b.new_sync_rule(
        audience_id_with_sync_rules, 
        7, 
        "http://ib.adnxs.com/seg?add=12345",
        "http://ib.adnxs.com/seg?remove=12345",
        "https://secure.ib.adnxs.com/seg?remove=12345",
        "https://secure.ib.adnxs.com/seg?remove=12345"
      )
      id.should == sync_rules(audience_id_with_sync_rules).sort(&by_id).last.id.to_s
    end

    it "#new_sync_rule with only add pixels should return id of new sync rule" do
      id = @b.new_sync_rule(
        audience_id_with_sync_rules, 
        7, 
        "http://ib.adnxs.com/seg?add=12345",
        nil,
        "https://secure.ib.adnxs.com/seg?add=12345",
        nil
      )
      id.should == sync_rules(audience_id_with_sync_rules).sort(&by_id).last.id.to_s
    end

    it "#new_sync_rule on request conditional audience should return id of new"+
    " sync rule" do
      id = @b.new_sync_rule(
        audience_id_with_request_condition, 
        7, 
        "http://ib.adnxs.com/seg?add=12345",
        "http://ib.adnxs.com/seg?remove=12345",
        "https://secure.ib.adnxs.com/seg?remove=12345",
        "https://secure.ib.adnxs.com/seg?remove=12345"
      )
      id.should == sync_rules(audience_id_with_request_condition).sort(&by_id).last.id.to_s
    end

    it "#new_sync_rule with missing arguments should raise error" do
      lambda {
        @b.new_sync_rule(
          last_audience_id, 
          "http://ib.adnxs.com/seg?remove=12345",
          "https://secure.ib.adnxs.com/seg?remove=12345",
          "https://secure.ib.adnxs.com/seg?remove=12345"
        )
      }.should raise_error(ArgumentError)
    end

    it "#sync_rule(audience_id, sync_rule_id) should return the details of a" +
    " single sync rule" do
      @agent.url = @api_root + "audiences"+
        "/#{audience_id_with_sync_rules}/sync_rules/#{sync_rule_id}"
      @agent.http_get
      resp = Hashie::Mash.new(JSON.parse(@agent.body_str))
      @b.sync_rule(audience_id_with_sync_rules, sync_rule_id).should == resp
    end

    it "#update_sync_rule with valid params should update the sync rule" do
      t_stamp = Time.now.to_i
      @b.update_sync_rule(
        audience_id_with_sync_rules, 
        sync_rule_id, 
        7,
        "http://ib.#{t_stamp}.com/seg?add=12345",
        "http://ib.#{t_stamp}.com/seg?remove=12345",
        "https://secure.#{t_stamp}.adnxs.com/seg?remove=12345",
        "https://secure.#{t_stamp}.adnxs.com/seg?remove=12345"
      ).should == ""
    end

    it "#delete_sync_rule(audience_id, sync_rule_id) should delete sync rule" do
      audience_id = audience_id_with_sync_rules
      sync_rules_in_order = sync_rules(audience_id).sort(&by_id)
      last_sync_rule_id = sync_rules_in_order.last.id
      sync_rule_count = sync_rules_in_order.size
      @b.delete_sync_rule(audience_id, last_sync_rule_id).should == ""
      @b.sync_rules(audience_id).sync_rules.size.should == sync_rule_count - 1
    end
  end

  # Request Conditions
  context "request condition admin" do

    before(:all) do
      @b.new_audience({ 
        :name => "new", 
        :audience_type => "request-conditional" })
      @audience_id = @b.audiences.audiences.sort(&by_id).last.id
    end

    it "#request_conditions(audience_id) should return Hashie::Mash object" +
    " containing request conditions associated with this audience if it is a"+
    " request-conditional type audience"  do
      @agent.url = 
        @api_root + "audiences/#{@audience_id}/request_conditions"
      @agent.http_get
      proper_response = Hashie::Mash.new(JSON.parse(@agent.body_str))
      @b.request_conditions(@audience_id).should == proper_response
    end

    it "#request_conditions(audience_id) should return message saying" +
    " 'Audience # is not request-conditional' if the audience requested is not"+
    " of type request-conditional" do
      audience_id = audience_id_with_sync_rules
      @b.request_conditions(audience_id).should == 
        "Audience #{audience_id} is not request-conditional"
    end

    it "#new_request_conditions(audience_id) should create a new request condition"+
      " for the audience" do
      @agent.url = 
        @api_root + "audiences/#{@audience_id}/request_conditions"
      @agent.http_get
      count = Hashie::Mash.new(JSON.parse(@agent.body_str)).request_conditions.size
      id = @b.new_request_condition(
        @audience_id, 
        :request_url_regex => "/aregexyo/", 
        :referrer_url_regex => "/anotheregexyo/"
      )
      id.should == request_conditions(@audience_id).sort(&by_id).last.id.to_s
      @agent.http_get
      new_count = 
        Hashie::Mash.new(JSON.parse(@agent.body_str)).request_conditions.size
      new_count.should == count + 1
    end

    it "#request_condition(audience_id, request_condition_id) should return"+
      " details for the request condition with the given id" do
      audience_id = audience_id_with_request_condition
      request_condition_id = request_conditions(audience_id).sort(&by_id).last.id
      @agent.url = 
        @api_root + "audiences/#{audience_id}/"+
        "request_conditions/#{request_condition_id}"
      @agent.http_get
      proper_response = Hashie::Mash.new(JSON.parse(@agent.body_str))
      @b.request_condition(audience_id, request_condition_id).should ==
        proper_response
    end

    it "#update_request_condition(audience_id, request_condition_id) should update"+
      " the request condition" do
      audience_id = audience_id_with_request_condition
      request_condition_id = request_conditions(audience_id).sort(&by_id).last.id
      time_as_int = Time.now.to_i
      @b.update_request_condition(
        audience_id, 
        request_condition_id, 
        :request_url_regex => "/anewtime#{time_as_int}/")
      @agent.url = 
        @api_root + "audiences/#{audience_id}/"+
        "request_conditions/#{request_condition_id}"
      @agent.http_get
      Hashie::Mash.new(JSON.parse(@agent.body_str)).request_url_regex.should ==
        "/anewtime#{time_as_int}/"
    end

    it "#delete_request_condition(audience_id, request_condition_id) should delete"+
      " the request condition" do
      audience_id = audience_id_with_request_condition
      request_condition_id = request_conditions(audience_id).sort(&by_id).last.id
      @b.delete_request_condition(audience_id, request_condition_id)
      @agent.url = 
        @api_root + "audiences/#{audience_id}/"+
        "request_conditions/#{request_condition_id}"
      @agent.http_get
      @agent.body_str.should == 
        "Request condition with id #{request_condition_id} not found"
    end
  end

  ## Load Operations
  context "load operation admin" do

    def load_operations(audience_id)
      @agent.url = 
        @api_root + "audiences/#{audience_id}/load_operations"
      @agent.http_get
      Hashie::Mash.new(JSON.parse(@agent.body_str)).load_operations
    end
    
    def audience_id_with_load_operations
      for audience in audiences_in_order
        if audience["type"] == 'xguid-conditional' && 
          !load_operations(audience.id).blank?
          return audience.id
        end
      end
      raise "No audience has load operations"
    end

    it "#load_operations(audience_id) should return all load operations for the"+
    " audience" do
      audience_id = audience_id_with_load_operations
      los_in_order = load_operations(audience_id).sort(&by_id)
      proper_response = los_in_order
      @b.load_operations(audience_id).load_operations.sort(&by_id).should == 
        proper_response
    end

    it "#load_operations(audience_id) should return an error string if the"+
    " audience id provided does not belong to an xguid-conditional audience" do
      audience_id = audience_id_with_request_condition
      @b.load_operations(audience_id).should == 
        "Audience #{audience_id} is not xguid-conditional"
    end

    it "#new_load_operation(audience_id) should create a new load operation" do
      audience_id = audience_id_with_load_operations
      count = load_operations(audience_id).size
      @b.new_load_operation(audience_id, "xg-live/prefix")
      @agent.url = 
        @api_root + "audiences/#{audience_id}/load_operations"
      @agent.http_get
      new_count = Hashie::Mash.new(JSON.parse(@agent.body_str)).load_operations.size
      new_count.should == count + 1
    end

    it "#load_operation(audience_id, load_operation_id) should return details of"+
    " of the load operation" do
      audience_id = audience_id_with_load_operations
      load_operation_id = load_operations(audience_id).sort(&by_id).first.id
      @agent.url = 
        @api_root + "audiences/#{audience_id}/load_operations"+
        "/#{load_operation_id}"
      @agent.http_get
      proper_response = Hashie::Mash.new(JSON.parse(@agent.body_str))
      @b.load_operation(audience_id, load_operation_id).should == proper_response
    end
  end
end
