class PartnersController < ApplicationController

  def index
    @partners = Partner.find(:all)
  end

  def new
    @partner = Partner.new
  end

  def create
    @partner = Partner.new(params[:partner])
    if @partner.save
      redirect_to campaigns_path
    else
      render :action => :new
    end
  end
end
