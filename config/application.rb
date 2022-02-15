require_relative 'boot'

require 'rails/all'
require 'csv'
require 'prometheus/client'
require 'prometheus/middleware/exporter'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cndtattend
  class Application < Rails::Application
    config.time_zone = 'Asia/Tokyo'
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(6.0)

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
    end

    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
    config.active_model.i18n_customize_full_message = true
    config.autoload_paths << "#{Rails.root}/app/middlewares"
    config.action_cable.mount_path = '/cable'
  end
end
