namespace :pagpos do

  desc 'Tracking package from post and save to DB'
  task :tracking => :environment do
    @tracking = Tracking.in(status: ['pending'])
    @tracking.each do |t|
      t.tracking_position
    end
  end

  desc "Send email notification"
  task :send_email_notification => :environment do
    @tracking = Tracking.in(status: ['pending'])
    @tracking.each do |t|
      begin
        unless t.packages.blank?
          tz = t.user.time_zone.blank? ? 0 : t.user.time_zone.to_i
          Time.zone = tz.zero? ? 'UTC' : tz
          t.enqueue_send_email_worker
        end
      rescue Exception => exception
        puts "#{Time.now } #{t.code} cannot add to queue #{exception}"
        t.update_attribute(:status, "error")
      end
    end

    if @tracking.blank?
      puts "#{Time.now } All tracking was done"
    end
  end
end