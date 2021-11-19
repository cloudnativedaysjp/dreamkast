Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.environment = ENV["DREAMKAST_NAMESPACE"]
  # config.environments = ['staging', 'production']
end
