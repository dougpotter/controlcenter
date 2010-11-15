class CreativesController < ApplicationController
  def index
    partner_id = params[:partner_id]
    campaign_code = params[:campaign_code]

    @partner_creatives = Set.new
    if partner_id != "" && !partner_id.nil?
      for campaign in Partner.find(partner_id).campaigns
        for creative in campaign.creatives
          @partner_creatives << creative
        end
      end
    end

    @campaign_creatives = Set.new
    if campaign_code != "" && !campaign_code.nil?
      for creative in Campaign.find(:first, :conditions => {:campaign_code => campaign_code}).creatives
        @campaign_creatives << creative
      end
    end

    @partner_creatives -= @campaign_creatives
    
    @unassociated_creatives = Set.new
    for creative in Creative.find(:all, :include => :campaigns)
      if creative.campaigns == []
        @unassociated_creatives << creative
      end
    end
    
    render :partial => 'creative_list'
    return
  end

  def new
    @creative = Creative.new
    @creatives = Creative.all
    @campaigns = Campaign.all
    @creative_sizes = CreativeSize.all(:order => 'common_name')
    @partners = Partner.all
  end

  def create
    @creative = Creative.new
    @creative.creative_size_id = params[:creative].delete(:creative_size)

    if !params[:creative][:campaigns].nil? && params[:creative][:campaigns] != ""
      @creative.campaigns << Campaign.find(params[:creative].delete(:campaigns))
    end

    @creative.attributes = params[:creative]
    
    if request.referer == new_campaign_url
      if @creative.save
        @creative = Creative.new
        @creative_sizes = CreativeSize.all(:order => 'common_name')
        render :partial => 'form_without_campaign'
        return
      else 
        render :text => ""
        return
      end
    else
      if @creative.save
        redirect_to new_creative_path
      else
        render :action => :new
        return
      end
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

  def form_without_campaign
    @creative = Creative.new
    @creative_sizes = CreativeSize.all
    render :partial => 'form_without_campaign'
  end
end
