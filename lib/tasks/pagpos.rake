require 'resque/tasks'

task "resque:setup" => :environment
task "resque:work"

namespace :pagpos do
  task :setup => :environment do
    include Mongoid::Document
  end

  desc 'Tracking package from post and save to DB'
  task :tracking => :environment do
    puts 'Checking tracking code to be add to queue'
    tracking = Tracking.where(status: 'pending')
    tracking.each do |t|
      t.tracking_position
    end
  end

  desc "Send notification by email"
  task :mail_notification => :environment do
    tracking = Tracking.where(status: 'pending')
    tracking.each do |t|
      Time.zone = t.user.try(:time_zone) || 'UTC'
      begin
        t.sendmail_asynchronously
        puts "Added tracking code to queue successfully!"
      rescue Exception => exception
        puts "Adding tracking code to queue failed!"
        t.update_attribute(:status, "error")
      end
    end

    if tracking.blank?
      puts "All tracking was done"
    end
  end

  desc "Send notification by sms"
  task :sms_notification => :environment do
    # TODO
  end  

  desc "Send notification by WhatsApp"
  task :whatsapp_notification => :environment do
    # TODO
  end

  desc "Send notification by Facebook"
  task :facebook_notification => :environment do
    # TODO
  end
end