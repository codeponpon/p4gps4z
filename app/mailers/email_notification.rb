class EmailNotification < ActionMailer::Base
  default :from => "PAGPOS <no-reply@pagpos.com>"
  default :to => "codePONPON<codeponpon@gmail.com>"

  def alert_reminder_email(tracking)
    @tracking = tracking
    @user = @tracking.user

    mail( subject: 'Package notifications', to: @user.email )
  end
end
