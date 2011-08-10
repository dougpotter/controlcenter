require 'spec_helper'

describe PartnersController, "create partner only with valid attributes" do

  before(:each) do
    @partner = mock("Partner", :save => true, :save_apn => true, :name => "name")
    Partner.expects(:new).returns(@partner)
  end

  after(:each) do
    Partner.delete_all_apn
  end

  def do_create
    post :create, :partner => {
      "partner_code" => "12345", 
      "name" => "partner name" }
  end

  it "should save @partner at xgcc and apn" do
    do_create
  end

  it "should be redirect" do
    do_create
    response.should redirect_to(new_partner_url)
  end
end

describe PartnersController, "create partner only with invalid attributes" do

  before(:each) do
    @partner = mock("Partner", :save => false)
    Partner.expects(:new).returns(@partner)
  end

  def do_create
    post :create, :partner => {:partner_code => "", :name => ""}
  end

  it "should fail to save @partner" do
    do_create
  end

  it "should render new action with errors" do
    do_create
    response.should render_template(:new)
  end
end

describe PartnersController, "destroy" do

  it "should call destroy on the partner whose id is passed in params[:id]"

  it "should redirect to new partner page" do
    pending
    @partner = Factory.create(:partner)
    delete :destroy, :id => @partner.id
    response.should redirect_to(new_partner_url)
  end
end
