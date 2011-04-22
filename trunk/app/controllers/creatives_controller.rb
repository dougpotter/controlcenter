class CreativesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  attr_accessor :apn_token

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
    @creatives = Creative.all(:joins => :creative_size)
    @campaigns = Campaign.all
    @creative_sizes = CreativeSize.all(:order => 'common_name')
    @partners = Partner.all
  end

  def create
    require 'image_spec'

    @creative = Creative.new
    if params[:creative][:image]
      creative_image = ImageSpec.new(params[:creative][:image])
      params[:creative][:creative_size] = CreativeSize.find_by_height_and_width(
        creative_image.height,
        creative_image.width
      )
    end

    if !params[:creative][:campaigns].blank?
      params[:creative][:campaigns] = params[:creative][:campaigns].to_a
      params[:creative][:campaigns].size.times do
        campaign = Campaign.find(params[:creative][:campaigns].pop)
        @creative.campaigns << campaign
      end
    end


    if params[:creative][:partner].blank?
      params[:creative][:partner] = nil
    else
      params[:creative][:partner] = Partner.find(params[:creative][:partner])
    end

    params[:creative][:creative_code] = Creative.generate_creative_code

    @creative.attributes = params[:creative]

    begin
      @creative.save!
      @creative.save_apn!
      redirect_to(new_creative_path, :notice => "creative successfully created")
    rescue
      @creatives = Creative.all(:joins => :creative_size)
      @campaigns = Campaign.all
      @creative_sizes = CreativeSize.all(:order => 'common_name')
      @partners = Partner.all
      render :action => "new"
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
    @partners = Partner.all
  end

  def update
    require 'image_spec'

    @creative = Creative.find(params[:id])
    if !params[:creative][:campaigns].blank?
      params[:creative][:campaigns] = 
        [ Campaign.find(params[:creative].delete("campaigns")) ].flatten
    end
    if params[:creative][:image] 
      creative_image = ImageSpec.new(params[:creative][:image])
      params[:creative][:creative_size] = CreativeSize.find_by_height_and_width(
        creative_image.height,
        creative_image.width
      )
    else
      params[:creative][:creative_size] = 
        @creative_size = CreativeSize.find(@creative.creative_size)
    end

    if params[:campaign_inventory_config]
      params[:campaign_inventory_config].each do |caic_id,configured|
        if configured == "1"
          @creative.configure(CampaignInventoryConfig.find(caic_id))
        else
          @creative.unconfigure(CampaignInventoryConfig.find(caic_id))
        end
      end    
    end

    params[:creative][:partner] = Partner.find(params[:creative][:partner])

    if @creative.update_attributes(params[:creative]) && 
      @creative.update_attributes_apn
      redirect_to(new_creative_path, :notice => "creative successfully updated")
    else
      redirect_to(new_creative_path, :notice => "something's wrong")
    end
  end

  def show
    @creative = Creative.find(params[:id])
  end

  def destroy
    @creative = Creative.find(params[:id]).destroy
    redirect_to(new_creative_path, :notice => "creative deleted")
  end

  def form_without_line_item
    @num = params[:creative_number]
    @creative = Creative.new
    @creative_sizes = CreativeSize.all
    render :partial => 'form_without_line_item', 
      :locals => { :creative_number => @num }
  end
end
