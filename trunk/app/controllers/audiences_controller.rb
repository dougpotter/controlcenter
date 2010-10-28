class AudiencesController < ApplicationController
  skip_before_filter :authenticate
  def new
    @audience = Audience.new
    @audience.audience_code ||= Audience.generate_audience_code
  end

  def create
    @audience = Audience.new(params[:audience])
    @audience.save!
    redirect_to campaigns_path
  rescue ActiveRecord::RecordInvalid
    render :action => :new
  end
end
