class AudiencesController < ApplicationController
  skip_before_filter :authenticate

  def index
    @audiences = Audience.find(:all)
  end

  def new
    @partners = Partner.all
    @audiences = Audience.find(:all)
    @audience = Audience.new
    @audience.audience_code ||= Audience.generate_audience_code
  end

  def create
    params[:audience][:campaign_id] = Campaign.find(params[:audience][:campaign_id]).id
    @audience = Audience.new(params[:audience])

    @audience_type = params[:audience_source].delete(:type)
    if @audience_type =="Ad-Hoc"
      @audience_source = AdHocSource.new(params[:audience_source])
    elsif @audience_type == "Retargeting"
      @audience_source = RetargetingSource.new(params[:audience_source])
    else
      raise "Audience type not supplied or type supplied was not recognized"
    end

    if @audience.save
      @audience << @audience_source
      redirect_to(new_audience_path)
    else
    end
  end

  def edit
    @audience = Audience.find(params[:id])
  end

  def update
    @audience = Audience.find(params[:id])
    if @audience.update_attributes(params[:audience])
      redirect_to :action => 'new'
    else
      render :action => 'edit', :id => @audience
    end
  end

  def audience_source_form
    if params[:source] == 'Retargeting'
      render :partial => 'form_for_retargeting_source'
    elsif params[:source] == 'Ad-Hoc'
      render :partial => 'form_for_ad_hoc_source'
    else
      render "invalid or absent audience type"
    end
  end

  def index_by_advertiser
    @audiences = []
    if params[:partner_id] == ""
      @audiences = Audience.all
    else
      @campaigns = Campaign.find_all_by_partner_id(params[:partner_id])
      if !@campaigns.nil?
        for campaign in @campaigns
          @audiences << campaign.audiences
        end
      end
    end
    @audiences.flatten!
    puts @audiences.size
    render :partial => 'layouts/edit_table', :locals => { :collection => @audiences, :header_names => ["Audience Code", "Description"], :fields => ["audience_code", "description"], :class_name => "audience_summary", :width => "500", :edit_path => edit_audience_path(1) }
  end
end
