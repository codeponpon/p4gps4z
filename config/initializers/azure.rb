if Rails.env.production?
  require "azure"
  Azure.configure do |config|
    # Configure these 2 properties to use Storage
    config.storage_account_name = "pps"
    # config.storage_access_key   = "3AmEjqH/OXqI01dfQpKs0RPgxAQ4CpxUkUFxgKVvgq15LU+K8QboqKuky8KMnZVSlQu8L3pQOutxWnMFHsNoTQ=="
    config.storage_access_key   = "k3+j1QJx7LQABVAtzoXiVaUQ6M0Zao4hL9I9d9w3p9hwskV7oGvo1nFYBUrJ+thdf4oqGwx8AYCW1ODY0nMdZw=="
    # Configure these 3 properties to use Service Bus
    # config.sb_namespace         = "<your azure service bus namespace>"
    # config.sb_access_key        = "<your azure service bus access key>"
    # config.sb_issuer            = "<your azure service bus issuer>"
  end
end  