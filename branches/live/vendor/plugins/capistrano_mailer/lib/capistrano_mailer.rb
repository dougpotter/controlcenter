require 'rubygems' unless defined?(Rubygems)
require 'capistrano' unless defined?(Capistrano)

# if rails3 activesupport is used with rails2 actionmailer:
#require 'active_support/core_ext/module/aliasing'
#require 'active_support/core_ext/kernel/reporting'

require 'action_mailer' unless defined?(ActionMailer)
require 'config/cap_mailer_settings'

module CapistranoMailer
  def send(cap_vars, extra = {}, data = {})
    CapMailer.deliver_notification_email(cap_vars, extra, data)
  end
end

Capistrano.plugin :mailer, CapistranoMailer
