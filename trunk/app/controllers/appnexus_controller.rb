# Rename this controller to AppnexusSyncController if other actions are needed.
class AppnexusController < ApplicationController
  def index
    @jobs = AppnexusSyncJob.all(:order => 'created_at desc')
  end
  
  def new
    @job_parameters = AppnexusSyncParameters.new(params[:appnexus_sync_parameters] || {})
  end
  
  def create
    if create_and_run_apn_sync_job('appnexus-list-generate', params[:appnexus_sync_parameters])
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def show
    @job = AppnexusSyncJob.find(params[:id])
    @job_parameters = AppnexusSyncParameters.new(@job.parameters)
  end
end
