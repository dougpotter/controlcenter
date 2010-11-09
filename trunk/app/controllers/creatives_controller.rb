class CreativesController < ApplicationController
  def index
    partner_id = params[:partner_id]

    @relevant_creatives = Set.new

    for campaign in Partner.find(partner_id).campaigns
      for creative in campaign.creatives
        @relevant_creatives << creative
      end
    end

    render :partial => 'creative_list'
  end

  def new
    @creative = Creative.new
    @all_creatives = Creative.all
    @campaigns = Campaign.all
    @creative_sizes = CreativeSize.all(:order => 'common_name')
  end

  def create
    @creative_size = CreativeSize.find(params[:creative].delete(:creative_size))
    @campaign = Campaign.find(params[:creative].delete(:campaigns))
    @creative = Creative.new(params[:creative])
    @creative.creative_size = @creative_size
    @creative.campaigns << @campaign
    if @creative.save
      redirect_to new_creative_path
    else
      render :action => :new
    end
  end

  def new_creative_line
    @creative_sizes = CreativeSize.all(:order => 'common_name')
    render :partial => 'form'
  end
end
