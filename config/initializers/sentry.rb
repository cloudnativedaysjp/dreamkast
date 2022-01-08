Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.environment = ENV['DREAMKAST_NAMESPACE']
  config.enabled_environments = ['dreamkast', 'dreamkast-staging'] # Only staging and production send error logs to sentry
end
