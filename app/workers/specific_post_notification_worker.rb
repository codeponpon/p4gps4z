class SpecificPostNotificationWorker  
  @queue = :specific_post_notification_queue
  
  def self.perform(tracking, reminder_by)
    if reminder_by == 'email'
      EmailNotification.specific_post(tracking).deliver
    elsif reminder_by == 'sms'
      # TODO
    elsif reminder_by == 'whatsapp'
      # TODO
    elsif reminder_by == 'facebook'
      # TODO
    else
      EmailNotification.specific_post(tracking).deliver
    end
  end
end