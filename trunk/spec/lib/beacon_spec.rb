require 'spec_helper'

describe Beacon do
  before(:all) do
    @audiences_as_mash = Hashie::Mash.new(JSON.parse(Curl::Easy.http_get(
            "http://aa.qa.xgraph.net/api/audiences"
    ).body_str))
    @audiences_in_order = @audiences_as_mash.audiences.sort { |x,y| x.id <=> y.id }
  end

  it "#audiences should return a hash of all audiences" do
    beacon_response = Beacon.new.audiences.audiences.sort { |x,y| x.id <=> y.id }
    beacon_response == @audiencnes_in_order
  end

  it "#audience(#) should return the audience with id of #" do
    correct_audience = 
      Hashie::Mash.new(JSON.parse(Curl::Easy.http_get(
        "http://aa.qa.xgraph.net/api/audiences/19"
    ).body_str))
    Beacon.new.audience(19).should == correct_audience
  end

  it "#new_audience with hash of legal params should create a new audience" do
    last_id = @audiences_in_order.last.id
    Beacon.new.new_audience({
      :name => "a new audience", :audience_type => "global", :active => "false"
    })
    Beacon.new.audiences.audiences.sort { |x,y| x.id <=> y.id }.last.id.should ==
      last_id + 1
  end

  it "#new_audience should return error with illegal attribute name" do
    Beacon.new.new_audience({
      :name => "a new audience", :type => "global", :active => "false"
    }).should == "Invalid value for audience type: null"
  end
end
