class LandingPagesController < ApplicationController
  def metrics 
    @partners = Partner.all(:order => :name)
    @campaigns = Campaign.all(:order => :campaign_code)
    @creatives = Creative.all(:order => :creative_code)
  end

  def update_form
    @partner = params[:partner_select].to_i
    @campaigns = Campaign.find(:all, :conditions => {:partner_id => @partner})
    @partners = Partner.find(:all)
    render :partial => 'form'
  end
end
