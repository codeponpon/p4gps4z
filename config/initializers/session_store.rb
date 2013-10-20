# Be sure to restart your server when you modify this file.
if ["production","staging"].include?(Rails.env)
  Pagpos::Application.config.session_store :cookie_store,
    # :memcache_server => (Rails.env.production? ? ['IP_MEMCHACH_SERVER'] : ['localhost']),
    :namespace => 'sessions',
    :key => '_pagpos_session',
    :expire_after => 1.minutes,
    :domain => :all
else
  Pagpos::Application.config.session_store :cookie_store, key: '_pagpos_session'
end