namespace :pagpos do

  desc 'Tracking package from PostOffice and save to DB'
  task :tracking_position => :environment do
    @tracking = Tracking.in(status: ['pending'])
    @tracking.each do |t|
      t.tracking_position
    end
  end

  desc "Send email notification"
  task :send_email_notification => :environment do
    @tracking = Tracking.in(status: ['pending'])
      @tracking.each do |t|
        if t.user.reminder_by.eql?('email')
          begin
            unless t.packages.blank?
              tz = t.user.time_zone.blank? ? 0 : t.user.time_zone.to_i
              Time.zone = tz.zero? ? 'UTC' : tz
              t.enqueue_send_email_worker
            end
          rescue Exception => exception
            puts "#{Time.now } #{t.code} cannot add to queue #{exception.message}"
            t.update_attribute(:status, "error")
          end
        end
      end

    if @tracking.blank?
      puts "#{Time.now } All tracking was done"
    end
  end

  desc "Send sms notification"
  task :send_sms_notification => :environment do
    @tracking = Tracking.in(status: ['pending'])
    @tracking.each do |t|
      if t.user.reminder_by.eql?('sms')
        begin
          unless t.packages.blank?
            tz = t.user.time_zone.blank? ? 0 : t.user.time_zone.to_i
            Time.zone = tz.zero? ? 'UTC' : tz
            t.enqueue_send_sms_worker
          end
        rescue Exception => exception
          puts "#{Time.now } #{t.code} cannot add to queue #{exception}"
          t.update_attribute(:status, "error")
        end
      end
    end

    if @tracking.blank?
      puts "#{Time.now } All tracking was done"
    end
  end
end