#Port 465: Used for SSL connections
#Port 587: Used for TLS connections
# ActionMailer::Base.smtp_settings = {
#   :address => "smtp.sendgrid.net",
#   :port => '587',
#   :domain => "pagpos.com",
#   :authentication => :plain,
#   :user_name => "",
#   :password => "",
#   :enable_starttls_auto => true
# }
if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => '587',
    :domain => "pagpos.com",
    :authentication => :plain,
    :user_name => "emailfortest.smtp@gmail.com",
    :password => "asdqwe!@#",
    :enable_starttls_auto => true
  }
else
  ActionMailer::Base.smtp_settings = {
    :address => "localhost", 
    :port => 1025
  }
end