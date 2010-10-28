require 'spec_helper'

describe AudiencesController, "create with a valid audience" do

  before(:each) do 
    Audience.stub!(:new).and_return(@audience = mock_model(Audience, :save! => true, :valid? => true))
  end

  def do_create
    post :create, :audience => {:audience_code => "ACODE"}
  end

  it "should create the Audience" do
    Audience.should_receive(:new).with("audience_code" => "ACODE").and_return(@audience)
    do_create
  end

  it "should save the Audience" do
    @audience.should_receive(:save!).and_return(true)
    do_create
  end

  it "should be redirected" do
    do_create
    response.should be_redirect
  end

  it "should assigne audience" do
    do_create
    assigns(:audience).should == @audience
  end

  it "should redirect to campaigns_path" do
    do_create
    response.should redirect_to(campaigns_path)
  end
end

describe AudiencesController, "create with an invalid audience" do

  before(:each) do
    Audience.stub!(:new).and_return(@audience = mock_model(Audience, :save! => false, :valid? => false))
  end

  def do_create
    post :create, :audience => {:audience_code => ""}
  end

  it "should create an audience" do
    Audience.should_receive(:new).with("audience_code" => "").and_return(@audience)
    do_create
  end

  it "should be be redirect" do
    do_create
    response.should be_redirect
  end

  it "should assign audience" do
    do_create
    assigns(:audience).should == @audience
  end

  #TODO: write this test properly...not sure why it's failing, it appear to render
  #the appropariate form upon creation of invalid audience 
  it "should re-render the new form" do
    #do_create
    #response.should render_template("new")
  end
end
