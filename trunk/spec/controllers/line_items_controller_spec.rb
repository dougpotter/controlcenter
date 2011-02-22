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
end
