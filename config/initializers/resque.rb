Dir[File.join(Rails.root, 'app', 'workers', '*.rb')].each { |file| require file if file.present? }

config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
Resque.redis = Redis.new(:host => config['host'], :port => config['port'])