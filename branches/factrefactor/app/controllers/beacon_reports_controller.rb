class BeaconReportsController < ApplicationController

  def index
    @partners = Partner.find(:all)
    @param_names = PartnerBeaconRequest.column_names - 
      ["id", "xguid", "xgcid", "puid", "pid"]
    @param_operators = ["=", "LIKE", "RLIKE"]
  end

  def show
    @graph = open_flash_chart_object(
      550, 300,
      "/beacon_report_graphs/#{params[:id]}?#{request.query_string}")
    @permalink = request.request_uri
    
    if request.xhr?
      render :partial => "show", :locals => { 
        :graph => @graph,
        :permalink => @permalink
      }
    end
  end
  
end
