conf = Rails.application.config_for(:redis)
$redis = if Rails.env.test?
  MockRedis.new
else
  Redis.new(host: conf["host"], port: conf["port"], db: conf["db"])
end
