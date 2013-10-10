class StatusChangeNotificationWorker  
  @queue = :status_change_notification_queue
  
  def self.perform(params)
    tracking, reminder_by = params
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