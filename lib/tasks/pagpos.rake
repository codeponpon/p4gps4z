namespace :pagpos do
  desc 'Tracking package from post and save to DB'
  task :tracking => :environment do
    puts 'Checking tracking code to be add to queue'
    tracking = Tracking.in(status: ['pending'])
    tracking.each do |t|
      t.tracking_position
    end
  end

  desc "Send notification by email"
  task :mail_notification => :environment do
    tracking = Tracking.in(status: ['pending'])
    tracking.each do |t|
      Time.zone = t.user.try(:time_zone) || 'UTC'
      begin
        t.sendmail_asynchronously
        puts "Added tracking code to queue successfully!"
      rescue Exception => exception
        puts "Adding tracking code to queue failed!"
        ErrorMailer.error_mail(exception).deliver if (Rails.env.production? or Rails.env.staging?)
        t.update_attribute(:status, "error")
        ExceptionNotifier::Notifier.background_exception_notification(exception)
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