class EmailNotification < ActionMailer::Base
  default :from => "PAGPOS <no-reply@pagpos.com>"
  default :to => "codePONPON<codeponpon@gmail.com>"

  def alert_reminder_email(tracking, reminder_when)
    @tracking = tracking
    @user = @tracking.user
    template_name = reminder_when
    mail( subject: 'Package notifications', to: @user.email, template_name: template_name )
  end

  def status_change(tracking)
    @tracking = tracking
    @user = @tracking.user
    mail( subject: 'Package status has changed', to: @user.email )

    Resque.enqueue(PushNotificationWorker, @tracking.code)
    @tracking.update_tracking_status
  end

  def specific_post(tracking)
    @tracking = tracking
    @user = @tracking.user
    mail( subject: 'Package notifications', to: @user.email )
  end
end
