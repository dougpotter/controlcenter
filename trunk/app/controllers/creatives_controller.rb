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
    @creatives = Creative.all
    @campaigns = Campaign.all
    @creative_sizes = CreativeSize.all(:order => 'common_name')
    @partners = Partner.all
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

  def index_by_advertiser
    @creatives = []
    if params[:partner_id] == ""
      @creatives = Creative.all
    else
      Campaign.find_all_by_partner_id(params[:partner_id]).each do |c|
        @creatives << c.creatives
      end
    end

    @creatives.flatten!

    render :partial => 'layouts/edit_table', :locals => { :collection => @creatives, :header_names => ["Creative Code", "Name", "Media Type", "Creative Size", "Campaign"], :fields => ["creative_code", "description", "media_type", "size_name", "campaign_descriptions"], :width => "1100", :class_name => "creatives_summary", :edit_path => edit_creative_path(1) }
  end

  def edit
    @creative = Creative.find(params[:id])
    @creative_sizes = CreativeSize.all
    @campaigns = Campaign.all
  end

  def update
    @creative = Creative.find(params[:id])
    @campaigns = Campaign.find(params[:creative].delete("campaigns")).to_a
    @creative_size = CreativeSize.find(params[:creative].delete("creative_size"))
    params[:creative][:campaigns] = @campaigns
    params[:creative][:creative_size] = @creative_size
    if @creative.update_attributes(params[:creative])
      redirect_to :action => :new
    else
      render :action => :edit
    end
  end
end
