class PartnersController < ApplicationController

  def index
    @partners = Partner.find(:all)
  end

  def new
    @partners = Partner.all
    @partner = Partner.new
  end

  def create
    @partner = Partner.new(params[:partner])
    if @partner.save
      redirect_to new_partner_path
    else
      render :action => :new
    end
  end

  def edit
    @partner = Partner.find(params[:id])
  end

  def update
    @partner = Partner.find(params[:id])
    if @partner.update_attributes(params[:partner])
      redirect_to :action => 'new'
    else
      render :action => 'edit', :id => @partner
    end
  end

end
