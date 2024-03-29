# See http://code.google.com/p/capistrano-mailer/
# Also, for GMail ActionMailer settings, see http://alexle.net/archives/278

require 'vendor/plugins/capistrano_mailer/lib/cap_mailer'
require 'vendor/plugins/action_mailer_tls/lib/smtp_tls'

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = { 
  :address        => "smtp.gmail.com", 
  :port           => 587, 
  :domain         => 'xgraph.com', 
  :perform_deliveries => true,
  :tls            => true,
  :enable_starttls_auto => true,
  :user_name      => "noreply@xgraph.com", 
  :password       => "", 
  :authentication => :plain
}
ActionMailer::Base.default_charset = "utf-8"# or "latin1" or whatever you are using

CapMailer.template_root = "vendor/plugins/capistrano_mailer/views/"
CapMailer.recipient_addresses = ["tech@xgraph.com"]
CapMailer.sender_address = %("Capistrano" <noreply@xgraph.com>)
CapMailer.email_prefix = "[XGCC-CAP-DEPLOY]"
CapMailer.site_name = "control.xgraph.com"
CapMailer.email_content_type = "text/html" # OR "text/plain" if you want the plain text version of the email
