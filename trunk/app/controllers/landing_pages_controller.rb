class LandingPagesController < ApplicationController
  def metrics 
    @partners = Partner.find(:all)
    @campaigns = Campaign.find(:all)
  end

  def update_form
    @partner = params[:partner_select].to_i
    @campaigns = Campaign.find(:all, :conditions => {:partner_id => @partner})
    @partners = Partner.find(:all)
    render :partial => 'form'
  end
end
