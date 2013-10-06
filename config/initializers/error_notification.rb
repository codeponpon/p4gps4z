if Rails.env.production? or Rails.env.staging?
  Pagpos::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => "[#{Rails.env}]PAGPOS",
    :sender_address => %{"notifier" <nore-ply@pagpos.com>},
    :exception_recipients => %w{errors@pagpos.com}
end