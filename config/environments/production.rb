require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  if ENV['REVIEW_APP']
    config.consider_all_requests_local       = true
  else
    config.consider_all_requests_local       = false
  end

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  # config.public_file_server.enabled = false

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { 'cache-control' => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT)
                                       .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
                                       .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = '/up'

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "cndtattend_production"
  config.active_job.queue_adapter = :sqs

  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
  config.action_mailer.perform_caching = false

  # Configure AWS SES for email delivery
  config.action_mailer.delivery_method = :ses_v2
  config.action_mailer.ses_v2_settings = { region: 'ap-northeast-1' }

  if ENV['REVIEW_APP'] == 'true'
    match = ENV['DREAMKAST_NAMESPACE'].match(/dreamkast-dev-dk-(\d+)-dk/) || ENV['DREAMKAST_NAMESPACE'].match(/dreamkast-dev-dk-(.*)-fifo-worker/)
    if match
      pr_number = match[1]
      Rails.application.routes.default_url_options[:host] = "dreamkast-dk-#{pr_number}.dev.cloudnativedays.jp"
    else
      raise "DREAMKAST_NAMESPACE is not set correctly (#{ENV['DREAMKAST_NAMESPACE']}). Please set it to dreamkast-dev-dk-<PR_NUMBER>-dk"
    end
  elsif ENV['S3_BUCKET'] == 'dreamkast-stg-bucket'
    Rails.application.routes.default_url_options[:host] = 'staging.dev.cloudnativedays.jp'
  elsif ENV['S3_BUCKET'] == 'dreamkast-prod-bucket'
    Rails.application.routes.default_url_options[:host] = 'event.cloudnativedays.jp'
  end


  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [:id]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  OmniAuth.config.on_failure = Proc.new do |env|
    message_key = env['omniauth.error.type']
    error_description = Rack::Utils.escape(env['omniauth.error'].error_reason)
    new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{message_key}&error_description=#{error_description}"
    Rack::Response.new(['302 Moved'], 302, 'Location' => new_path).finish
  end
end
