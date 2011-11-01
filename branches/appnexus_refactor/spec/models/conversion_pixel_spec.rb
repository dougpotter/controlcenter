require 'spec_helper'

## Appnexus Stuff
describe ConversionPixel do
  before(:all) do
    @a = Curl::Easy.new
    @a.url = APN_CONFIG['api_root_url'] + "auth"
    @a.enable_cookies = true
    @a.post_body = APN_CONFIG["authentication_hash"].to_json
    @a.http_post
  end

  it "all_apn should return all conversion pixels for the given advertiser" do
    @a.url = APN_CONFIG['api_root_url'] + "pixel?advertiser_code=77777"
    @a.http_get
    pixels = JSON.parse(@a.body_str)["response"]["pixels"]
    ConversionPixel.all_apn("77777").should == pixels
  end
end
