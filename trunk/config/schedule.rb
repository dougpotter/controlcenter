# Use this file to define tasks that need to be executed periodically.

# Note: our deployment configuration automatically updates crontab
# on target system to execute tasks defined in this file (schedule.rb).
# In order to temporarily prevent a task defined here from running,
# you can comment out the appropriate line(s) in the target system's
# crontab. To access crontab for another user, use -u argument to crontab
# like this:
#
# sudo crontab -e -u www
#
# Keep in mind that deploying the application will put the tasks back into
# the target's crontab. If you are deploying code and want to avoid the
# tasks being put back into the target crontab, comment out the following
# line in deploy.rb which arranges for the crontab to be updated:
#
# after "deploy:symlink", "deploy:update_crontab"
#
# This needs to be done in addition to commenting out the entry in remote
# crontab.

# Clearspring files seem to mostly materialize a couple minutes after each
# hour mark, with some exceptions. Running extraction exactly on the hour
# is asking for race conditions. Run extraction 15 minutes before every hour.
every 1.hour, :at => 45 do
  rake 'workflows:clearspring:autorun'
end

# It is helpful to understand cron before editing this file:
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
