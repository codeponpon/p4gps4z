module SmsSdk
  def self.send_to(to_number, body)
    result = Hash.new({})
    begin
      # Get your Account Sid and Auth Token from twilio.com/user/account
      account_sid = 'AC933633a223a501e8c2b9fae7fd62b3e0'
      auth_token = 'd832f6c4a3f485d4eb6c3182b538a1c0'
      from_number = "+14436028231" # Replace with your Twilio number
      client = Twilio::REST::Client.new(account_sid, auth_token)
      message = client.account.sms.messages.create(:body => body, :to => to_number, :from => from_number)
      result = {code: 200, sent: true, message: message.sid}
    rescue Twilio::REST::RequestError => error
      result = {code: 401, sent: false, message: error.message}
    end
  end
end