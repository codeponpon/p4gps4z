class SendEmailWorker
  @queue = :send_email_worker_queue
  
  def self.perform(params)
    tracking_id, reminder_when, specific_department = params
    if reminder_when == 'specific_post' && specific_department
      EmailNotification.specific_post(tracking_id).deliver
      puts "Added Status specific post notifiction to queue successfully!"
    elsif reminder_when == 'status_change'
      EmailNotification.status_change(tracking_id).deliver
      puts "Added Status change notifiction to queue successfully!"
    end
  end
end