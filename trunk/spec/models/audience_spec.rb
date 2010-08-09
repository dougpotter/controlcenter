# == Schema Information
# Schema version: 20100803143344
#
# Table name: audiences
#
#  id                 :integer(4)      not null, primary key
#  description        :text
#  internal_external  :text
#  seed_extraction_id :integer(4)
#  model_id           :integer(4)
#

require 'spec_helper'

describe Audience do
  before(:each) do
    @seed_extraction = SeedExtraction.new({
      :description => "desc",
      :mapper => "mapper",
      :reducer => "reducer"
    })
    @seed_extraction.save
    @model = Model.new({
      :description => "desc",
    })
    @model.save
    @valid_attributes = {
      :description => "3XM5",
      :internal_external => "external",
      :seed_extraction_id => @seed_extraction.id,
      :model_id => @model.id 
    }
  end

  it "should create a new instance given valid attributes" do
    Audience.create!(@valid_attributes)
  end

  it "should require a parent seed extraction (db test)" do
    lambda {
      Audience.create!(@valid_attributes.merge({:seed_extraction_id => @seed_extraction.id + 1}))
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require a parent model (db test)" do
    lambda {
      Audience.create!(@valid_attributes.merge({:model_id => @model.id + 1}))
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require an integer seed_extraction_id (db test)" do
    lambda {
      a = Audience.new(@valid_attributes.merge({:seed_extraction_id => "not an int"}))
      a.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require an integer model_id (db test)" do
    lambda {
      a = Audience.new(@valid_attributes.merge({:model_id => "not an int"}))
      a.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require integer seed_extraction_id (validation test)" do
    a = Audience.new(@valid_attributes.merge({:seed_extraction_id => "not an int"}))
    a.save.should eql(false)
  end

  it "should require integer model_id (validation test)" do
    a = Audience.new(@valid_attributes.merge({:model_id => "not an int"}))
    a.save.should eql(false)
  end
end
