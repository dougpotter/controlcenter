require 'spec_helper'

describe PartnersController, "create with valid attributes" do

  before(:each) do
    @partner = mock(:save => true)
  end

  def do_create
    post :create, :partner => {"partner_code" => "ABCD", "name" => "partner name"}
  end

  it "should assign @partner" do
    Partner.expects(:new).with("partner_code" => "ABCD", "name" => "partner name").returns(@partner)
    do_create
    assigns(:partner).should == @partner
  end

  it "should save @partner" do
    Partner.expects(:new).with("partner_code" => "ABCD", "name" => "partner name").returns(@partner)
    do_create
  end

  it "should be redirect" do
    Partner.expects(:new).with("partner_code" => "ABCD", "name" => "partner name").returns(@partner)
    do_create
    response.should be_redirect
  end

end

describe PartnersController, "create with invalid attributes" do

  before(:each) do
    @partner = mock(:save => false)
  end

  def do_create
    post :create, :partner => {:partner_code => "", :name => ""}
  end

  it "should assign @partner" do
    Partner.expects(:new).with("partner_code" => "", "name" => "").returns(@partner)
    do_create
    assigns(:partner).should == @partner
  end

  it "should fail to save @partner" do
    Partner.expects(:new).with("partner_code" => "", "name" => "").returns(@partner)
    do_create
  end

  it "should render new action" do
    Partner.expects(:new).with("partner_code" => "", "name" => "").returns(@partner)
    do_create
    response.should render_template('new')
  end
end
