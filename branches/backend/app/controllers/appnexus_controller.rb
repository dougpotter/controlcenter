# Rename this controller to AppnexusSyncController if other actions are needed.
class AppnexusController < ApplicationController
  def index
    now = Time.now
    do_list(now.year, now.month)
  end
  
  def list
    do_list(params[:year].to_i, params[:month].to_i)
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
        headers = s3_client.head(bucket, file)
        #headers = {}
        [name, bucket, file, headers['content-length'].to_i]
      end
    end
  end
  
  def show_log
    s3_client = S3Client::RightAws.new
    url = s3_client.signed_file_url(params[:bucket], params[:path], 1.hour)
    redirect_to url
  end
  
  private
  
  def do_list(year, month)
    @year, @month = year, month
    if month == 1
      @prev_year = year - 1
      @prev_month = 1
    else
      @prev_year = year
      @prev_month = month - 1
    end
    if month == 12
      @next_year = year + 1
      @next_month = 1
    else
      @next_year = year
      @next_month = month + 1
    end
    
    start_date = Time.utc(year, month)
    end_date =  Time.utc(@next_year, @next_month)
    @jobs = AppnexusSyncJob.all(:order => 'created_at desc',
      :conditions => ['created_at >= ? and created_at < ?', start_date, end_date])
    
    render :action => 'list'
  end
end
