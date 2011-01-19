# == Schema Information
# Schema version: 20101220202022
#
# Table name: impression_counts
#
#  campaign_id              :integer(4)      not null
#  creative_id              :integer(4)      not null
#  ad_inventory_source_id   :integer(4)      not null
#  geography_id             :integer(4)
#  audience_id              :integer(4)      not null
#  impression_count         :integer(4)      not null
#  start_time               :datetime
#  end_time                 :datetime
#  duration_in_minutes      :integer(4)
#  id                       :integer(4)      not null, primary key
#  media_purchase_method_id :integer(4)
#

require 'spec_helper'
require 'factory_girl'
describe ImpressionCount do

  it "should require valid foreign key for campaigns" do
    lambda {
      Factory.create(:impression_count, :campaign_id => 0)
    }.should raise_error
  end

  it "should require valid foreign key for creatives" do
    lambda {
      Factory.create(:impression_count, :creative_id => 0)
    }.should raise_error
  end

  it "should require valid foreign key for ad inventory sources" do
    lambda {
      Factory.create(:impression_count, :ad_inventory_source_id => 0)
    }.should raise_error
  end

  it "should require valid foreign key for audiences" do
    lambda {
      Factory.create(:impression_count, :audience_id => 0)
    }.should raise_error
  end

  it "should require a numerical impression count" do 
    lambda {
      Factory.create(:impression_count, :impression_count => "not a numba")
    }.should raise_error
  end

  it "should require a start time that occurs before end time" do
    lambda {
      Factory.create(:impression_count, {:start_time => Time.now + 60, :end_time => Time.now})
    }.should raise_error
  end

  it "should require a unique combination of required dimensions" do
    impression_count = Factory.build(:impression_count)
    attributes = impression_count.attributes
    impression_count.save
    lambda {
      Factory.create(:impression_count, attributes)
    }.should raise_error
  end

  it "should require non null impression_count (validations test)" do
    lambda {
      Factory.create(:impression_count, :impression_count => nil)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require non null impression_count (db test)" do
    lambda {
      i = Factory.build(:impression_count, :impression_count => nil)
      i.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  describe "with cache-based validation" do
    include ActiveRecordErrorParsingHelper
    fixtures :creatives, 
      :campaigns, 
      :line_items, 
      :ad_inventory_sources, 
      :audiences, 
      :campaigns_creatives, 
      :ad_inventory_sources_campaigns

    it "should create new instance with valid attributes" do
      lambda {
        DimensionCache.reset
        DimensionCache.seed_relationships
        i = ImpressionCount.new({ 
          :campaign_id => 1, 
          :creative_id => 1, 
          :ad_inventory_source_id => 1, 
          :audience_id => 1, 
          :start_time => Time.now, 
          :end_time => (Time.now + 100), 
          :duration_in_minutes => 100, 
          :impression_count => 1019
        })
        i.save!
      }.should_not raise_error
    end

    it "should not create new instance with invalid attribute relationship" do
      lambda {
        DimensionCache.reset
        DimensionCache.seed_relationships
        i = ImpressionCount.new({ 
          :campaign_id => 2, 
          :creative_id => 2, 
          :ad_inventory_source_id => 1, 
          :audience_id => 1, 
          :start_time => Time.now, 
          :end_time => (Time.now + 100), 
          :duration_in_minutes => 100, 
          :impression_count => 1019
        })
        i.save!
      }.should raise_error(ActiveRecord::RecordInvalid) { |error| 
        error.record.errors.select { |e| 
          e[1] == "this is an unknown relationship: campaign_id:2:creative_id:2"
        }.empty?.should == false 
      }
    end

    it "should not create a new instance with an unrecognized attribute_code" do
      lambda {
        i = ImpressionCount.new({ 
        :campaign_code => "ABC1", 
        :creative_code => "AA19", 
        :ais_code => "AdX", 
        :audience_code => "AB17", 
        :start_time => Time.now, 
        :end_time => (Time.now + 100), 
        :duration_in_minutes => 100, 
        :click_count => 1019
      })  
      i.save!
      }.should raise_error(ActiveRecord::RecordInvalid) { |error| 
        contains_unrecognized_code_error?(
          error,
          error.record.attributes_on_initialize_as_hsh[:creative_code]
        ).should == true
      }
    end
  end
end
