# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :authenticate

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  # Create headers necessary for proper CSV file generation
  # Grabbed from http://stackoverflow.com/questions/94502/
  def render_csv(options={})
    # Set filename to ultimately requested file by default, and force appending
    # of .csv
    filename = options[:filename]
    filename ||= CGI::escape(request.path.gsub(/^.*\//, ""))
    filename += '.csv' unless filename =~ /\.csv$/

      # String#index returns nil if no match is found
      if request.env['HTTP_USER_AGENT'].index("MSIE")
        headers['Pragma'] = 'public'
        headers["Content-type"] = "text/plain" 
        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
        headers['Expires'] = "0" 
      else
        headers["Content-Type"] ||= 'text/csv'
        headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
      end

    if block_given?
      require 'fastercsv'
      text = FasterCSV.generate do |csv|
        yield csv
      end
      render :text => text
    elsif data = options[:data]
      require 'fastercsv'
      text = FasterCSV.generate do |csv|
        data.each do |line|
          csv << line
        end
      end
      render :text => text
    else
      render :layout => false
    end

  end

  private

  def create_and_run_apn_sync_job(name, parameters)
    @job = AppnexusSyncJob.new
    @job.name = name
    @job_parameters = AppnexusSyncParameters.new(parameters)
    if @job_parameters.valid?
      @job.parameters = @job_parameters.attributes
      @job.save!
      @job.run
      return true
    else
      return false
    end
  end

  # Authenticate via HTTP Basic Authentication
  # See http://rails.nuvvo.com/lesson/6378
  # TODO: Replace with user database and permission system
  def authenticate
    if defined?(APPWALL_USERNAME)
      authenticate_or_request_with_http_basic do |username, password|
        !(APPWALL_USERNAME.blank?) && username == APPWALL_USERNAME && 
          Digest::MD5.hexdigest(password) == APPWALL_PASSWORD_HASH
      end
    end
  end
end
