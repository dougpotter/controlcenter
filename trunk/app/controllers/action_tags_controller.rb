class ActionTagsController < ApplicationController
  def sid
    render :text => ActionTag.generate_sid
  end

  def index
    @partner = Partner.find(params[:partner_id])
    @action_tags = @partner.action_tags

    respond_to do |format|
      format.txt  { send_data((render :layout => false), :filename => "#{@partner.name}_action_tags.txt", :disposition => "attachment") }
      format.html { send_data((render :layout => false), :filename => "#{@partner.name}_action_tags.html", :disposition => "attachment") }
    end
  end
end
