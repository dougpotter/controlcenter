require 'spec_helper'

describe ConversionConfiguration do

  it "should create a new instance given valid attributes" do
    Factory.create(:conversion_configuration)
  end

  for attr in 
    [ :conversion_configuration_code, :name, :partner_id, :audience_source_id ]
    it "should not allow blank #{attr}" do
      lambda {
        Factory.create(:conversion_configuration, attr => nil)
      }.should raise_error(ActiveRecord::RecordInvalid)
    end
  end

  it "#request_regex should return the request regex of the associated audience source" do
    cc = Factory.create(:conversion_configuration)
    cc.request_regex.should == cc.audience_source.request_regex
  end

  it "#referer_regex should return the referer regex of the associated audience source" do
    cc = Factory.create(:conversion_configuration)
    cc.referer_regex.should == cc.audience_source.referrer_regex
  end
end
