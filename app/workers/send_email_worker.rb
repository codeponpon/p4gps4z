class SendEmailWorker
  @queue = :send_email_worker_queue
  
  def self.perform(params)
    tracking_id, user_id, reminder_when = params
    user = User.where(_id: user_id).first
    packages = Package.where(tracking_id: tracking_id).first
    if reminder_when == 'specific_post' && user.specific_department == packages.last.department
      EmailNotification.specific_post(tracking_id).deliver
      puts "Added Status specific post notifiction to queue successfully!"
    elsif reminder_when == 'status_change'
      EmailNotification.status_change(tracking_id).deliver
      puts "Added Status change notifiction to queue successfully!"
    end
  end
end