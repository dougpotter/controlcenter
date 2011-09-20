require 'spec_helper'

describe ActionTag do
  it "should create new action tag with valid attributes" do
    p = Factory.create(:partner)
    a = Factory.build(:action_tag, :partner_id => p.id)
    a.save
  end

  [:name, :sid, :url, :partner_id].each do |attr|
    it "should fail to save if #{attr} is blank (validations test)" do
      lambda {
        Factory.create(:action_tag, attr => nil)
      }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should fail to save if #{attr} is blank (db test)" do
      lambda {
        a = Factory.build(:action_tag, attr => nil)
        a.save(false)
      }.should raise_error(ActiveRecord::StatementInvalid)
    end
  end

  it "should url-encode name" do
    a = Factory.create(:action_tag, :name => "two words")
    a.name.should == "two+words"
  end

  it "should fail to save with sid of length 6" do
    lambda {
      Factory.create(:action_tag, :sid => 123456)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should fail to save with sid of length 4" do
    lambda {
      Factory.create(:action_tag, :sid => 1234)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should not allow duplicate sids" do
    lambda {
      Factory.create(:action_tag, :sid => 12345)
      Factory.create(:action_tag, :sid => 12345)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end
end
