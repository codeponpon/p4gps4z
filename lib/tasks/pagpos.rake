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
      begin
        unless t.packages.blank?
          tz = t.user.time_zone.blank? ? 0 : t.user.time_zone.to_i
          Time.zone = tz.zero? ? 'UTC' : Time.zone.now.in_time_zone(tz).zone
          reminder_when = t.user.reminder_when
          tracking_id   = t.id
          user_id       = t.user_id.to_s
          Resque.enqueue(SendEmailWorker, [tracking_id, user_id, reminder_when])
        end
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