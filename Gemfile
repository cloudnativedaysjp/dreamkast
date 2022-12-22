source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.4'
# Use Puma as the app server
gem 'puma', '~> 6.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Prometheus client
gem 'prometheus-client', '~> 4.0.0'

gem 'icalendar'
gem 'rack-cors'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# OmniAuth Auth0 strategy and CSRF protection
gem 'omniauth-auth0', '~> 3.0'
gem 'omniauth-rails_csrf_protection', '~> 1.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'committee'
  gem 'committee-rails'
  gem 'simplecov'
  gem 'rubocop', '~> 1.40.0'
  gem 'rubocop-rails'
  gem 'rubocop-rspec', '>= 2.0.0'
  gem 'annotate', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  gem 'pry-rails'
  gem 'bullet'
  gem 'rbs'
  gem 'steep', require: false
  gem 'rbs_rails', require: false
  gem 'pre-commit', require: false
  gem 'execjs', require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'

  gem 'rexml', '~> 3.2', '>= 3.2.4'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "mysql2", "~> 0.5.4"

gem "sentry-ruby"
gem "sentry-rails"

gem "redis-rails"

gem "shrine", "~> 3.3"

gem "aws-sdk-s3", "~> 1.14"

gem 'seed-fu'

gem 'rails_autolink'

gem "rack-timeout"

gem "pundit"

gem 'redcarpet'

# processing images
gem "uppy-s3_multipart", "~> 1.0"
gem "image_processing", "~> 1.12.2"

gem 'awesome_nested_set', github: "collectiveidea/awesome_nested_set"
gem 'aws-sdk-rails'

gem 'activerecord-nulldb-adapter'

gem 'slack-incoming-webhooks'

gem "octokit", "~> 6.0"
gem 'psych', '< 6'

gem "aws-sdk-ivs"
gem "aws-sdk-medialive"
gem "aws-sdk-mediapackage"
gem "aws-sdk-ssm"

gem 'active_hash'

gem 'newrelic_rpm'

gem "http", "~> 5.1"
