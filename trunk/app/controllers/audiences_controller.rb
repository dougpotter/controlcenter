class AudiencesController < ApplicationController
  skip_before_filter :authenticate

  def index
    @audiences = Audience.find(:all)
  end

  def new
    @audiences = Audience.find(:all)
    @audience = Audience.new
    @audience.audience_code ||= Audience.generate_audience_code
  end

  def create
    @audience = Audience.new(params[:audience])
    if @audience.save
      redirect_to campaigns_path
    else
      @audiences = Audience.find(:all)
      render :action => :new
    end
  end

  def edit
    @audience = Audience.find(params[:id])
  end

  def update
    @audience = Audience.find(params[:id])
    if @audience.update_attributes(params[:audience])
      redirect_to :action => 'index'
    else
      render :action => 'edit', :id => @audience
    end
  end
end
