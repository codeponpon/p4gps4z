require 'sms/sms_sdk'

class SendSmsWorker
  @queue = :send_sms_worker_queue
  
  def self.perform(params)
    phone_no, message, reminder_when, specific_department = params
    if reminder_when == 'specific_post' && specific_department
      SmsSdk.send_to(phone_no, message)
    elsif reminder_when == 'status_change'
      SmsSdk.send_to(phone_no, message)
    end
  end
end