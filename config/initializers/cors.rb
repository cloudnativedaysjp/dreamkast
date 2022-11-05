Rails.application.config.middleware.insert_before(0, Rack::Cors) do
  allow do
    origins ENV['DREAMKAST_UI_BASE_URL'] || 'https://*.cloudnativedays.jp'
    resource '*', methods: :any, headers: :any
  end
end
