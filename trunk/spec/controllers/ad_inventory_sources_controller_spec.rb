require 'spec_helper'

describe AdInventorySourcesController, "create with valid attributes" do
before(:each) do
    @ais = mock(:save => true)
  end

  def do_create
    post :create, :ais => {"ais_code" => "ABCD", "name" => "ais name"}
  end

  it "should assign @ais" do
    AdInventorySource.expects(:new).with("ais_code" => "ABCD", "name" => "ais name").returns(@ais)
    do_create
    assigns(:ais).should == @ais
  end

  it "should save @ais" do
    AdInventorySource.expects(:new).with("ais_code" => "ABCD", "name" => "ais name").returns(@ais)
    do_create
  end

  it "should be redirect" do
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
    post :create, :ais => {:ais_code => "", :name => ""}
  end

  it "should assign @ais" do
    AdInventorySource.expects(:new).with("ais_code" => "", "name" => "").returns(@ais)
    do_create
  end

  it "should fail to save @ais" do
    AdInventorySource.expects(:new).with("ais_code" => "", "name" => "").returns(@ais)
    do_create
  end

  it "should render new action" do
    AdInventorySource.expects(:new).with("ais_code" => "", "name" => "").returns(@ais)
    do_create
    response.should render_template('new')
  end
end

describe AdInventorySourcesController, "destroy" do
  it "should delete ais with id passed in params[:id]" do
    @ais = Factory.create(:ad_inventory_source)
    AdInventorySource.expects(:destroy).with(@ais.id.to_s).returns(@ais)
    delete :destroy, :id => @ais.id
  end

  it "should redirect to new ad inventory source page" do
    @ais = Factory.create(:ad_inventory_source)
    delete :destroy, :id => @ais.id
    response.should redirect_to(new_ad_inventory_source_url)
  end
end
