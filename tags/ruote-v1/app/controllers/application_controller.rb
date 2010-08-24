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
  def render_csv(filename = nil)
    filename ||= params[:action]
    filename += '.csv'
    
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

    render :layout => false
  end

  private
  
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
