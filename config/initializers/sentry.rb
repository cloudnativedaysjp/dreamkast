Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
end

Sentry.set_tags("dreamkast_namespace": ENV["DREAMKAST_NAMESPACE"])
