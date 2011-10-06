class CampaignCreative < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :creative
end
