Rails.application.config.middleware.insert_before(0, Rack::Cors) do
  allow do
    origins ENV['DREAMKAST_UI_BASE_URL'] || %r{https://.*\.cloudnativedays\.jp}, %r{https://emtec-intermission-git-.*-emtec\.vercel\.app}, %r{https://emtec-intermission\.vercel\.app}
    resource '*', methods: :any, headers: :any
  end
end
