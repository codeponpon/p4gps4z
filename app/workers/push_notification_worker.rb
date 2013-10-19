class PushNotificationWorker
  @queue = :mobile_push_notification_queue

  def self.perform(tracking_code)
    tracking = Tracking.where(code: tracking_code).first
    channel = tracking.user.reminder_when

    alert_text = ''
    case channel
    when 'status_change'
      alert_text = "Your status package was change"
    when 'specific_post'
      alert_text = "You package send to specific post"
    else
      alert_text = "Your status package was change"
    end

    data = { :alert => alert_text }
    push = Parse::Push.new(data, channel)
    push.type = "android" # "ios" To push to iOS devices, you must first configure a valid certificate.
    status = push.save
    if status["result"]
      puts "Push notification to android already"  
    end
  end
end