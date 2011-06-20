require 'spec_helper'

describe LineItemsController do
  context "create" do

    def do_create
      post :create, 
        :line_item => {
        :name => "Ford Spring",
        :line_item_code => "AB12",
        :start_time => "February 12, 2010",
        :end_time => "March 12, 2010",
        :partner_id => 1
      }
    end

    context "with valid attributes" do
      before(:each) do
        @line_item = mock("Line Item", :save => true)
      end

      it "should assign @line_item" do
        LineItem.expects(:new).with({
          "name" => "Ford Spring",
          "line_item_code" => "AB12",
          "start_time" => "February 12, 2010",
          "end_time" => "March 12, 2010",
          "partner_id" => 1
        }).returns(@line_item)
        do_create
        assigns(:line_item).should == @line_item
      end

      it "should save @line_item" do
        LineItem.expects(:new).with({
          "name" => "Ford Spring",
          "line_item_code" => "AB12",
          "start_time" => "February 12, 2010",
          "end_time" => "March 12, 2010",
          "partner_id" => 1
        }).returns(@line_item)
        do_create
      end

      it "should be redirect" do
        LineItem.expects(:new).with({
          "name" => "Ford Spring",
          "line_item_code" => "AB12",
          "start_time" => "February 12, 2010",
          "end_time" => "March 12, 2010",
          "partner_id" => 1
        }).returns(@line_item)
        do_create
        response.should be_redirect
      end
    end

    context "with invalid attributes" do
      before(:each) do
        @line_item = mock("Line Item", :save => false)
      end

      it "should assign @line_item" do
        LineItem.expects(:new).with({
          "name" => "Ford Spring",
          "line_item_code" => "AB12",
          "start_time" => "February 12, 2010",
          "end_time" => "March 12, 2010",
          "partner_id" => 1
        }).returns(@line_item)
        do_create
        assigns(:line_item).should == @line_item
      end

      it "should fail to save @line_item" do
        LineItem.expects(:new).with({
          "name" => "Ford Spring",
          "line_item_code" => "AB12",
          "start_time" => "February 12, 2010",
          "end_time" => "March 12, 2010",
          "partner_id" => 1
        }).returns(@line_item)
        do_create
      end

      it "should re-render new" do
        LineItem.expects(:new).with({
          "name" => "Ford Spring",
          "line_item_code" => "AB12",
          "start_time" => "February 12, 2010",
          "end_time" => "March 12, 2010",
          "partner_id" => 1
        }).returns(@line_item)
        do_create
        response.should render_template(:new)
      end
    end
  end

  context "update" do
    fixtures :line_items

    def do_update 
      post :update, { :id => 1, 
        :line_item => { 
          :name => "Ford Spring", 
          :line_item_code => "ABCD", 
          :partner_id => 1 
        } 
      } 
    end

    context "with valid attributes" do
      before(:each) do
        @line_item = mock("Line Item", :update_attributes => true)
      end

      it "should find @line_item" do
        LineItem.expects(:find).with("1").returns(@line_item)
        do_update
        assigns(:line_item).should == @line_item
      end

      it "should update @line_item" do
        LineItem.expects(:find).with("1").returns(@line_item)
        do_update
      end

      it "response should redirect to new line item" do
        LineItem.expects(:find).with("1").returns(@line_item)
        do_update
        response.should redirect_to(new_line_item_path)
      end
    end

    context "with invalid attributes" do
      before(:each) do
        @line_item = mock("Line Item", :update_attributes => false)
      end

      it "should find @line_item" do
        LineItem.expects(:find).with("1").returns(@line_item)
        do_update
        assigns(:line_item).should == @line_item
      end
      
      it "should update @line_item" do
        LineItem.expects(:find).with("1").returns(@line_item)
        do_update
      end

      it "response should redirect to edit line item" do
        LineItem.expects(:find).with("1").returns(@line_item)
        do_update
        response.should redirect_to(edit_line_item_path(1))
      end
    end
  end

  context "destroy" do

    before(:each) do
      @line_item = Factory.create(:line_item)
    end

    def do_delete
      delete :destroy, :id => @line_item.id
    end

    it "should delete a line line item when its id is passed in params[:id]" do
      do_delete
      response.should redirect_to(new_line_item_path)
    end

    it "should delete a line item with one creative-less campaign" do
      @campaign = Factory.create(:campaign)
      @campaign.line_item = @line_item
      @campaign.save

      expect {
        do_delete
      }.to change{ Campaign.all.count }.by(-1)
    end

    it "should delete a line item with associated creatives" do
      @creative = Factory.create(:creative)
      @creative.line_items << @line_item
      @creative.save

      expect {
        do_delete
      }.to change{ Creative.all.count }.by(-1)
    end

  end
end
