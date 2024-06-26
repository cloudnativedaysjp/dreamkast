Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger, :redis_logger]
  config.dsn = ENV['SENTRY_DSN']
  config.environment = ENV['DREAMKAST_NAMESPACE']
  config.enabled_environments = ['dreamkast', 'dreamkast-staging'] # Only staging and production send error logs to sentry

  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:
  config.traces_sample_rate = 0.0001
  config.profiles_sample_rate = 0.0001
  # set the instrumenter to use OpenTelemetry instead of Sentry
  config.instrumenter = :otel

  config.before_send_transaction = lambda do |event, _hint|
    # Sentry への接続 transaction 自体は Sentry に送らない
    return nil if event.transaction == 'connect'

    event
  end
end
