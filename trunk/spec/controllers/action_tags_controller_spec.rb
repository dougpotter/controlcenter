require 'spec_helper'

describe ActionTagsController do

  it "#sid should return a valid SID" do
    get :sid
    at = Factory.build(:action_tag, :sid => response.body)
    at.valid?.should be_true
  end

end
