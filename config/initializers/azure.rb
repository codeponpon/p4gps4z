if Rails.env.production?
  require "azure"
  Azure.configure do |config|
    # Configure these 2 properties to use Storage
    config.storage_account_name = "pgsig"
    config.storage_access_key   = "CJfvu/pFalCma6oYO7UbmLCs6KHKP3DZcv59DuA1ba8nbNz0U+2YhoTYwGI4RJTvbSgCZrOaIinGdAjSVotrIQ=="
    # Configure these 3 properties to use Service Bus
    # config.sb_namespace         = "<your azure service bus namespace>"
    # config.sb_access_key        = "<your azure service bus access key>"
    # config.sb_issuer            = "<your azure service bus issuer>"
  end
end  