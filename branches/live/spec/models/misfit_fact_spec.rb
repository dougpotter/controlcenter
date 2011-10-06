require 'spec_helper'

describe MisfitFact do
  it "should create MisfitFact given valid attributes" do
    Factory.create(:misfit_fact)
  end

  it "should require non-null fact_class" do
    lambda {
      Factory.create(:misfit_fact, :fact_class => nil)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require non-null fact_attributes" do
    lambda {
      Factory.create(:misfit_fact, :fact_attributes => nil)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require non-null anomaly" do
    lambda {
      Factory.create(:misfit_fact, :anomaly => nil)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require fact_class to be an actual Fact class (with non-existent class)" do
    lambda {
      m = Factory.build(:misfit_fact, :fact_class => "not_a_fact_class")
      m.save!
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require fact_class to be an actual Fact class (with non-fact class that actually exists)" do
    lambda {
      m = Factory.build(:misfit_fact, :fact_class => "Partner")
      m.save!
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require fact_class to be an actual Fact class (with actual fact class)" do
    lambda {
      m = Factory.build(:misfit_fact, :fact_class => "click_count")
      m.save!
    }.should_not raise_error
  end

  it "should require an anomly of type String" do
    lambda {
      Factory.create(:misfit_fact, :anomaly => 123)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require anomaly to be properly formatted (dimension values should only contain uppercase letters - value anomaly test)" do
    lambda {
      Factory.create(:misfit_fact, :anomaly => "partner_code:12a")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require anomaly to be properly formatted (dimension names should be all lowercase - value anomaly test)" do
    lambda {
      Factory.create(:misfit_fact, :anomaly => "Partner_code:12AM")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require anomaly to be properly formatted (dimension values should only contain uppercase letters - relationship anomaly test)" do
    lambda {
      Factory.create(:misfit_fact, :anomaly => "partner_code:12a:creative_code:1AB2")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require anomaly to be properly formatted (dimension names should be all lowercase - relationship anomaly test)" do
    lambda {
      Factory.create(:misfit_fact, :anomaly => "Partner_code:12AM:creative_code:123A")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end
end
