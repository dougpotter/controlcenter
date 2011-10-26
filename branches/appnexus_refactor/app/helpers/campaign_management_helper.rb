module CampaignManagementHelper
  def new_partner_option
    "<option value=''>New partner</option>"
  end

  def blank_partner_option
    "<option value=''>-</option>"
  end
  
  def all_select_option
    "<option value=''>All</option>"
  end

  def style_entry_box(campaign, ais)
    if campaign.ad_inventory_sources.member?(ais)
      "visibility:visible;"
    else
      "visibility:hidden;"
    end
  end
end
