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
    @audience = Audience.new(params[:audience])
    if @audience.save
      redirect_to :action => :new
    else
      @audiences = Audience.find(:all)
      render :action => :new
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
