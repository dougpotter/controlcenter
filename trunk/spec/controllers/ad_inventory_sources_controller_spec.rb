require 'spec_helper'

describe AdInventorySourcesController, "create with valid attributes" do
before(:each) do
    @ais = mock(:save => true, :valid? => true)
  end

  def do_create
    post :create, :ad_inventory_source => {"ais_code" => "ABCD", "name" => "ais name"}
  end

  it "should assign @ais" do
    AdInventorySource.expects(:new).with("ais_code" => "ABCD", "name" => "ais name").returns(@ais)
    AdInventorySource.expects(:save)
    do_create
    assigns(:ais).should == @ais
  end

  it "should save @ais" do
    AdInventorySource.expects(:new).with("ais_code" => "ABCD", "name" => "ais name").returns(@ais)
    AdInventorySource.expects(:save).returns(:true)
    do_create
  end

  it "should be redirect" do
    AdInventorySource.expects(:new).with("ais_code" => "ABCD", "name" => "ais name").returns(@ais)
    AdInventorySource.expects(:save)
    do_create
    response.should be_redirect
  end


end

describe AdInventorySourcesController, "create with invalid attributes" do

  before(:each) do
    @ais = mock(:valid? => false, :save => false)
  end

  def do_create
    post :create, :ad_inventory_source => {:ais_code => "", :name => ""}
  end

  it "should assign @ais" do
    AdInventorySource.expects(:new).with("ais_code" => "", "name" => "").returns(@ais)
    AdInventorySource.expects(:save)
    do_create
    assigns(:ais).should == @ais
  end

  it "should fail to save @ais" do
    AdInventorySource.expects(:new).with("ais_code" => "", "name" => "").returns(@ais)
    AdInventorySource.expects(:save)
    do_create
  end

  it "should render new action" do
    AdInventorySource.expects(:new).with("ais_code" => "", "name" => "").returns(@ais)
    AdInventorySource.expects(:save)
    do_create
    response.should render_template('new')
  end
end
