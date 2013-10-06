# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
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
# every :hour, :day, :month, :year, :reboot
# every :sunday .. :saturday, :weekend, :weekday
# every 0 0 27-31 * *
# every :day, :at => '12:20am', :roles => [:app]

set :output, File.join(Dir.getwd, 'tmp', 'logs', 'cron_log.log')
set :environment, 'development'

every :reboot do
  rake "resque:workers COUNT=5 QUEUE=*"
end

every 1.minute do 
  rake "pagpos:tracking"
  rake "pagpos:mail_notification"
end