class CreativesController < ApplicationController
  def index
    partner_id = params[:partner_id]
    campaign_code = params[:campaign_code]

    @partner_creatives = Set.new
    if !partner_id.blank?
      creatives = Creative.all(
        :joins => { :campaigns => { :line_item => :partner } }
      )
      for creative in creatives
        if creative.campaigns.first.line_item.partner.id == partner_id.to_i
          @partner_creatives << creative
        end
      end
    end

    @campaign_creatives = Set.new
    if !campaign_code.blank?
      for creative in Campaign.find(
        :first, 
        :conditions => {:campaign_code => campaign_code}
      ).creatives
      @campaign_creatives << creative
      end
    end

    # remove duplicates (creatives associated with both the parter and a campaign
    # for that partner)
    @partner_creatives -= @campaign_creatives

    @unassociated_creatives = Set.new
    for creative in Creative.find(:all, :include => :campaigns)
      if creative.campaigns.empty?
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

    if !params[:creative][:campaigns].blank?
      campaign_ids = params[:creative][:campaigns]
      for campaign_id in campaign_ids
        campaign = Campaign.find(campaign_id)
        @creative.campaigns << campaign
        for campaign_inventory_config in campaign.campaign_inventory_configs
          @creative.creative_inventory_configs << campaign_inventory_config
        end
      end
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
    if params[:partner_id].blank?
      @creatives = Creative.all
    else
      creatives = Creative.all(
        :joins => { :campaigns => { :line_item => :partner }}, 
        :conditions => { "partners.id" => params[:partner_id] }
      )
      for creative in creatives
        @creatives << creative
      end
    end

    @creatives.uniq!

    render :partial => 'layouts/edit_table', 
      :locals => { 
      :collection => @creatives, 
      :header_names => [
        "Creative Code", 
        "Name", 
        "Media Type", 
        "Creative Size", 
        "Campaign"
    ], 
      :fields => [
        "creative_code", 
        "name", 
        "media_type", 
        "size_name", 
        "campaign_descriptions"
    ], 
      :width => "1100", 
      :class_name => "creatives_summary", 
      :edit_path => edit_creative_path(1) 
    }
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
      redirect_to :action => :edit
    end
  end

  def show
    @creative = Creative.find(params[:id])
  end

  def form_without_line_item
    @num = params[:creative_number]
    @creative = Creative.new
    @creative_sizes = CreativeSize.all
    render :partial => 'form_without_line_item', 
      :locals => { :creative_number => @num }
  end
end
