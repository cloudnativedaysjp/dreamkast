Rails.application.config.middleware.insert_before(0, Rack::Cors) do
  allow do
    origins(%r{https://.*\.cloudnativedays\.jp})
    resource '*', methods: :any, headers: :any
  end
end
