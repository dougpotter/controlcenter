# Rename this controller to AppnexusSyncController if other actions are needed.
class AppnexusController < ApplicationController
  def index
    @jobs = AppnexusSyncJob.all(:order => 'created_at desc')
  end
  
  def new
    @job_parameters = AppnexusSyncParameters.new(params[:appnexus_sync_parameters] || {})
  end
  
  def create
    if create_and_run_appnexus_sync_job(
      'appnexus-list-generate',
      params[:appnexus_sync_parameters] || {}
    )
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def show
    @job = AppnexusSyncJob.find(params[:id])
    @job_parameters = AppnexusSyncParameters.new(@job.parameters)
    if emr_log_uri = @job.emr_log_uri
      s3_client = S3Client::RightAws.new
      bucket, path = S3PrefixSpecification.parse_uri_str(emr_log_uri)
      @log_files = s3_client.list_bucket_files(bucket, path)
      @log_files.map! do |file|
        name = file[path.length+1...file.length]
        [name, bucket, file]
      end
    end
  end
  
  def show_log
    s3_client = S3Client::RightAws.new
    url = s3_client.signed_file_url(params[:bucket], params[:path], 1.hour)
    redirect_to url
  end
end
