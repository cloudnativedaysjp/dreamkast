require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load middleware classes before application configuration
require_relative '../app/middlewares/dreamkast_exporter'
require_relative '../app/middlewares/rescue_from_invalid_authenticity_token'

module Cndtattend
  class Application < Rails::Application
    config.time_zone = 'Asia/Tokyo'
    config.i18n.default_locale = :ja
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(7.1)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.generators do |g|
      g.test_framework(:rspec,
                       fixtures: true,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: true,
                       request_specs: false)
      g.fixture_replacement(:factory_bot, dir: 'spec/factories')
    end

    config.middleware.use(DreamkastExporter, path: '/metrics')
    config.middleware.use(RescueFromInvalidAuthenticityToken)

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
    config.active_model.i18n_customize_full_message = true
    config.action_cable.mount_path = '/cable'
  end
end
