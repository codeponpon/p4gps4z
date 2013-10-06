class NotificationPositionWorker  
  @queue = :email_notification_queue
  
  def self.perform(tracking_code)
    @tracking = Tracking.where(code: tracking_code).first
    EmailNotification.alert_reminder_email(@tracking).deliver
  end
end