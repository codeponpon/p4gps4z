namespace :pagpos do

  desc 'Tracking package from post and save to DB'
  task :tracking => :environment do
    puts 'Checking tracking code to be add to queue'
    get_pendings
    @tracking.each do |t|
      Resque.enqueue(TrackingPositionWorker, t.code)
    end
  end

  desc "Send email notification"
  task :send_email_notification => :environment do
    get_pendings
    @tracking.each do |t|
      tz = t.user.time_zone.blank? ? 0 : t.user.time_zone.to_i
      Time.zone = tz.zero? ? 'UTC' : Time.zone.now.in_time_zone(tz).zone
      
      begin
        reminder_when = t.user.reminder_when        
        Resque.enqueue(SendEmailWorker, [t, reminder_when])
      rescue Exception => exception
        puts "#{t.code} cannot add to queue"
        t.update_attribute(:status, "error")
      end
    end

    if @tracking.blank?
      puts "All tracking was done"
    end
  end
end

def get_pendings
  @tracking = Tracking.in(status: ['pending'])
end