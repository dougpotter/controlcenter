require 'spec_helper'

describe PartnersController, "create partner with valid attributes" do
  context "and no action tags or conversion pixels" do
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

  context "and valid action tags and no conversion pixels" do
    def do_create
      post :create, :partner => {
        "partner_code" => "12345",
        "name" => "partner name",
        "action_tags_attributes" => {
          "0" => {
            "name" => "sitewide",
            "sid" => "54321", 
            "url" => "http://a.url" } } }
    end

    it "should associate the action tag with the partner" do
      @action_tag = mock("ActionTag", :partner_id= => 1)
      ActionTag.expects(:new).returns(@action_tag)
      @action_tags_collection = mock("action_tags_collection")
      @action_tags_collection.expects("<<").with(@action_tag).returns([@action_tag])
      @partner = mock(
        "Partner", 
        :save => true, 
        :save_apn => true, 
        :id => 1, 
        :action_tags => @action_tags_collection,
        :name => "partner name"
      )
      Partner.expects(:new).returns(@partner)
      do_create
    end
  end
end

describe PartnersController, "create partner only with invalid attributes" do
  context "and no action tags or conversion pixels" do
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
end
