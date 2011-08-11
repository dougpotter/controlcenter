require 'spec_helper'

describe PartnersController, "create partner with valid attributes" do
  before(:each) do
    @partner = mock("Partner", :save => true, :save_apn => true)
    Partner.expects(:new).returns(@partner)
  end

  context "and no action tags" do
    context "or conversion pixels" do
      def do_create
        post :create, :partner => {
          "partner_code" => "12345", 
          "name" => "partner name" }
      end

      before(:each) do
        @partner.expects(:name).returns("partner name")
      end

      it "should save @partner at xgcc and apn" do
        do_create
      end

      it "should be redirect" do
        do_create
        response.should redirect_to(new_partner_url)
      end
    end # or conversion pixels

    context "and valid conversion pixel" do
      def do_create
        post :create, :partner => { 
          "partner_code" => "12345",
          "name" => "partner name",
          "conversion_pixels_attributes" => { 
            "0" => {
              "name" => "conv pixel name",
              "request_regex" => "a regex for request",
              "referrer_regex" => "a regex for referrer" } } }
      end

      before(:each) do
        @partner.expects(:name).returns("partner name")
        @partner.expects(:partner_code).returns("12345")
        @conversion_pixel = mock(
          "ConversionPixel", 
          :partner_code= => "12345",
          :save_apn => true
        )
        ConversionPixel.expects(:new).returns(@conversion_pixel)
      end

      it "should associate conversion pixel" do
        do_create
      end

      it "should be redirect" do
        do_create
        response.should redirect_to(new_partner_url)
      end

    end

    context "and invalid conversion pixel" do
      def do_create
        post :create, :partner => { 
          "partner_code" => "12345",
          "name" => "partner name",
          "conversion_pixels_attributes" => {
            "0" => { 
              "name" => "conv pixel name",
              "request_regex" => "",
              "referrer_regex" => "" } } }
      end

      before(:each) do
        @partner.expects(:partner_code).returns("12345")
        @partner.expects(:destroy).returns(@partner)
        @partner.expects(:attributes).returns({ "a" => "hash" })
        Partner.expects(:new).
          with({ "a" => "hash" }).returns(mock("Partner (new from old attrs)"))
        Partner.expects(:all).returns([ mock("Partner (one of pre-existing)") ])
        @conversion_pixel = mock(
          "ConversionPixel", :partner_code= => "12345", :save_apn => false
        )
        ConversionPixel.expects(:new).returns(@conversion_pixel)
      end

      it "should fail to save conversion pixel" do
        do_create
      end

      it "should render new action" do
        do_create
        response.should render_template(:new)
      end
    end
  end # and no action tags

  context "and valid action tags" do
    context "and no conversion pixels" do
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
        @action_tag = mock("ActionTag")
        ActionTag.expects(:new).returns(@action_tag)
        @action_tags_collection = mock("action_tags_collection")
        @action_tags_collection.expects("<<").
          with(@action_tag).returns([@action_tag])
        @partner.expects(:action_tags).returns(@action_tags_collection)
        @partner.expects(:name).returns("partner name")
        do_create
      end

      context "and valid conversion pixels" do
        def do_create
          post :create, :partner => { 
          "partner_code" => "12345",
          "name" => "partner name",
          "action_tags_attributes" => {
            "0" => {
              "name" => "sitewide",
              "sid" => "54321", 
              "url" => "http://a.url" } },
          "conversion_pixels_attributes" => {
            "0" => {
              "name" => "conv pixel name",
              "referrer regex" => "a regex for referrer",
              "request regex" => "a regex for requests" } } }
        end

        it "should associate action tags"

        it "should associate conversion pixels"

        it "should be redirect"

      end

      context "and invalid conversion pixel" do
        def do_create
          post :create, :partner => { 
          "partner_code" => "12345",
          "name" => "partner name",
          "action_tags_attributes" => {
            "0" => {
              "name" => "sitewide",
              "sid" => "54321", 
              "url" => "http://a.url" } },
          "conversion_pixels_attributes" => {
            "0" => {
              "name" => "conv pixel name",
              "referrer regex" => "",
              "request regex" => "" } } }
        end

        it "should fail to save conversion pixel"

        it "should render new action"

      end
    end # and valid action tags
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
