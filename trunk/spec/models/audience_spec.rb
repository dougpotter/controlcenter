# == Schema Information
# Schema version: 20101220202022
#
# Table name: audiences
#
#  id            :integer(4)      not null, primary key
#  description   :string(255)
#  audience_code :string(255)     not null
#  campaign_id   :integer(4)
#

require 'spec_helper'

describe Audience do

  it "should create a new instance given valid attributes" do
    Factory.create(:audience)
  end

  it "should require an audience code" do
    lambda {
      Factory.create(:audience, :audience_code => nil)
    }.should raise_error
  end

  it "should require a unique audience code (validations test)" do
    lambda {
      Factory.create(:audience, :audience_code => "same")
      Factory.create(:audience, :audience_code => "same")
    }.should raise_error
  end

  it "should require a unique audience code (db test)" do
    lambda {
      Factory.create(:audience, :audience_code => "same")
      f = Factory.build(:audience, :audience_code => "same")
      f.save(false)
    }.should raise_error
  end

  it "should require non null audience code (validations test)" do
    lambda {
      Factory.create(:audience, :audience_code => nil)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require non null audience code (db test)" do
    lambda {
      a = Factory.build(:audience, :audience_code => nil)
      a.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  context "\#sources_in_order" do
    it "should return audience sources in order of increasing iteration number" do
      audience = Factory.create(:audience)
      audience_source1 = Factory.create(:ad_hoc_source)
      audience_source2 = Factory.create(:ad_hoc_source)
      audience.audience_sources << audience_source1
      audience.audience_sources << audience_source2
      audience.sources_in_order.should == [ audience_source1, audience_source2 ]
    end
  end

  context "\#iteration_number" do
    it "should return 0 if audience is on the first iteration" do
      audience = Factory.create(:audience)
      audience_source = Factory.create(:ad_hoc_source)
      audience.audience_sources << audience_source
      audience.iteration_number.should == 0
    end

    it "should return 1 if audience is on the second iteration" do
      audience = Factory.create(:audience)
      audience_source1 = Factory.create(:ad_hoc_source)
      audience_source2 = Factory.create(:ad_hoc_source)
      audience.audience_sources << audience_source1
      audience.audience_sources << audience_source2
      audience.iteration_number.should == 1
    end

    it "should return 0 after second iteration is deleted" do
      audience = Factory.create(:audience)
      audience_source1 = Factory.create(:ad_hoc_source)
      audience_source2 = Factory.create(:ad_hoc_source)
      audience.audience_sources << audience_source1
      audience.audience_sources << audience_source2
      audience.audience_sources[-1].destroy
      audience.iteration_number.should == 0
    end
  end

  context "\#update_source" do
    context "with Ad-Hoc source" do
      it "should add new audience manifest when passed it's first source" do
        audience = Factory.create(:audience)
        audience_source = Factory.create(:ad_hoc_source)
        expect {
          audience.update_source(audience_source)
        }.to change{ AudienceManifest.count }.by(1)
      end

      it "should add new audience manifest when passed it's second source" do
        audience = Factory.create(:audience)
        audience_source1 = Factory.create(:ad_hoc_source)
        audience.update_source(audience_source1)
        audience_source2 = Factory.create(:ad_hoc_source)
        expect {
          audience.update_source(audience_source2)
        }.to change{ AudienceManifest.count }.by(1)
      end

      it "should raise exception if new audience source does not share type of existing audience source" do
        audience = Factory.create(:audience)
        audience_source1 = Factory.create(:ad_hoc_source)
        audience.update_source(audience_source1)
        audience_source2 = Factory.create(:retargeting_source)
        lambda {
          audience.update_source(audience_source2)
        }.should raise_error
      end

      it "should do nothing if source passed has the same s3 bucket" do
        audience = Factory.create(:audience)
        audience_source1 = Factory.create(
          :ad_hoc_source, 
          :s3_bucket => "same_bucket:/a/path"
        )
        audience.update_source(audience_source1)
        audience_source2 = Factory.create(
          :ad_hoc_source, 
          :s3_bucket => "same_bucket:/a/path"
        )
        expect {
          audience.update_source(audience_source2)
        }.to change{ AudienceManifest.count }.by(0)
        audience.iteration_number.should == 0
      end
    end

    context "with Regargeting source" do
      it "should add new audience manifest when passed it's first source" do
        audience = Factory.create(:audience)
        audience_source = Factory.create(:retargeting_source)
        expect {
          audience.update_source(audience_source)
        }.to change{ AudienceManifest.count }.by(1)
      end

      it "should add new audience manifest when passed it's second source" do
        audience = Factory.create(:audience)
        audience_source1 = Factory.create(:retargeting_source)
        audience.update_source(audience_source1)
        audience_source2 = Factory.create(:retargeting_source)
        expect {
          audience.update_source(audience_source2)
        }.to change{ AudienceManifest.count }.by(1)
      end

      it "should raise exception if new audience source does not share type of existing audience source" do
        audience = Factory.create(:audience)
        audience_source1 = Factory.create(:retargeting_source)
        audience.update_source(audience_source1)
        audience_source2 = Factory.create(:ad_hoc_source)
        lambda {
          audience.update_source(audience_source2)
        }.should raise_error
      end
    end
  end

  context "\#latest_source" do
    it "should return the source of the latest iteration" do
        audience = Factory.create(:audience)
        audience_source = Factory.build(:retargeting_source)
        audience.update_source(audience_source)
        audience.latest_source.should == audience_source
    end
  end
end
