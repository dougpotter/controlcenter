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
end
