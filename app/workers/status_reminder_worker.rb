class StatusReminderWorker
  @queue = :status_reminder_queue

  def self.perform(tracking_code)
    @tracking = Tracking.where(code: tracking_code).first
    @user = @tracking.user
    
    if @user.reminder_when == 'specific_time'
      # When the time specific
    elsif @user.reminder_when == 'specific_post'
      # When the package to specific post
    else 
      EmailNotification.alert_reminder_email(@tracking).deliver
    end    
  end
end