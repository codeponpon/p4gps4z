require 'sms/sms_sdk'

class SendSmsWorker
  @queue = :send_sms_worker_queue
  
  def self.perform(params, tracking_id)
    phone_no, message, reminder_when, specific_department= params
    result = if(reminder_when == 'specific_post' && specific_department)
      SmsSdk.send_to(phone_no, message)
    elsif(reminder_when == 'status_change')
      SmsSdk.send_to(phone_no, message)
    end
    if result[:code].eql?(200)
      Tracking.where(_id: tracking_id).first.update_tracking_status
      puts "sms has been sent"
    else
      puts "sms status #{result[:code]}, #{result[:message]}"
    end
  end
end