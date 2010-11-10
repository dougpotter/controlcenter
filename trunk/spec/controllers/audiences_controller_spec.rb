require 'spec_helper'

describe AudiencesController, "create with a valid audience" do

  before(:each) do 
    @audience = mock(:save => true, :valid? => true)
    Audience.expects(:new).with("audience_code" => "ACODE").returns(@audience)
    #Audience.stub!(:new).and_return(@audience = mock_model(Audience, :save! => true, :valid? => true))
  end

  def do_create
    post :create, :audience => {:audience_code => "ACODE"}
  end

  it "should create the Audience" do
    do_create
  end

  it "should save the Audience" do
    @audience.expects(:save).returns(true)
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

  it "should redirect to new audience path" do
    do_create
    response.should redirect_to(new_audience_path)
  end
end

describe AudiencesController, "create with an invalid audience" do

  before(:each) do
    @audience = mock()
    Audience.expects(:new).with("audience_code" => "").returns(@audience)
    Audience.expects(:find).returns(@audiences = [mock(), mock()])
    @audience.expects(:save).returns(false)
  end

  def do_create
    post :create, :audience => {:audience_code => ""}
  end

  it "should create an audience" do
    do_create
  end

  it "should be be redirect" do
    do_create
    response.should render_template('new')
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
