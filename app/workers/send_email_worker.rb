class SendEmailWorker
  @queue = :send_email_worker_queue
  
  def self.perform(params)
    tracking_obj, reminder_when = params
    user = User.where(_id: tracking_obj.user_id).first
    packages = Package.where(tracking_id: tracking_obj.id).first
    if reminder_when == 'specific_post' && user.specific_department == packages.last.department
      EmailNotification.specific_post(tracking_obj).deliver
      puts "Added Status specific post notifiction to queue successfully!"
    elsif reminder_when == 'status_change'
      EmailNotification.status_change(tracking).deliver
      puts "Added Status change notifiction to queue successfully!"
    end
  end
end