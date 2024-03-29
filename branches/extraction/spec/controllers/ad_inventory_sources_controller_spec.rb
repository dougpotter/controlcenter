require 'spec_helper'

describe AdInventorySourcesController, "create with valid attributes" do
before(:each) do
    @ais = mock(:save => true)
  end

  def do_create
    post :create, :ad_inventory_source => {"ais_code" => "ABCD", "name" => "ais name"}
  end

  it "should assign @ais" do
    pending
    AdInventorySource.expects(:new).with("ais_code" => "ABCD", "name" => "ais name").returns(@ais)
    do_create
    assigns(:ais).should == @ais
  end

  it "should save @ais" do
    pending
    AdInventorySource.expects(:new).with("ais_code" => "ABCD", "name" => "ais name").returns(@ais)
    do_create
  end

  it "should be redirect" do
    pending
    AdInventorySource.expects(:new).with("ais_code" => "ABCD", "name" => "ais name").returns(@ais)
    do_create
    response.should be_redirect
  end


end

describe AdInventorySourcesController, "create with invalid attributes" do

  before(:each) do
    @ais = mock(:save => false)
  end

  def do_create
    post :create, :ad_inventory_source => {:ais_code => "", :name => ""}
  end

  it "should assign @ais" do
    pending
    AdInventorySource.expects(:new).with("ais_code" => "", "name" => "").returns(@ais)
    do_create
    assigns(:ais).should == @ais
  end

  it "should fail to save @ais" do
    pending
    AdInventorySource.expects(:new).with("ais_code" => "", "name" => "").returns(@ais)
    do_create
  end

  it "should render new action" do
    pending
    AdInventorySource.expects(:new).with("ais_code" => "", "name" => "").returns(@ais)
    do_create
    response.should render_template('new')
  end
end
