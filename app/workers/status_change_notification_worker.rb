class StatusChangeNotificationWorker  
  @queue = :status_change_notification_queue
  
  def self.perform(tracking_code)
    tracking = Tracking.where(code: tracking_code).first
    user = tracking.user
    reminder_by = user.reminder_by
    reminder_when = user.reminder_when
    if reminder_by == 'email'
      EmailNotification.status_change(tracking).deliver
    elsif reminder_by == 'sms'
      # TODO
    elsif reminder_by == 'whatsapp'
      # TODO
    elsif reminder_by == 'facebook'
      # TODO
    else
      EmailNotification.status_change(tracking).deliver
    end
  end
end