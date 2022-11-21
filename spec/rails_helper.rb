# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts(e.to_s.strip)
  exit(1)
end

Rails.logger = Logger.new(STDOUT) # Rails.loggerを出す
ActiveRecord::Base.logger = Logger.new(STDOUT) # SQLログ出す

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.include(ActiveSupport::Testing::TimeHelpers)


  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include(FactoryBot::Syntax::Methods)

  config.add_setting(:committee_options)
  config.committee_options = {
    schema_path: Rails.root.join('schemas', 'swagger.yml').to_s,
  }
  include Committee::Rails::Test::Methods
  config.include(ActiveJob::TestHelper)
end

def claim
  [JSON.parse('{
    "https://cloudnativedays.jp/roles": [
      "CNDT2022-Admin",
      "CNSEC2022-Admin"
    ],
    "https://cloudnativedays.jp/userinfo": {
      "given_name": "Kazuto",
      "family_name": "Kusama",
      "nickname": "jacopen",
      "name": "Kazuto Kusama (jacopen)",
      "picture": "https://lh3.googleusercontent.com/a-/AFdZucpvEjNRZYjV2ke2VoVckmoW_OOJCP9s68RUj04kPHs=s96-c",
      "locale": "en",
      "email": "jacopen@example.com",
      "email_verified": true
    },
    "iss": "https://dreamkast.us.auth0.com/",
    "sub": "google-oauth2|101793385802092207080",
    "aud": [
      "https://event.cloudnativedays.jp/",
      "https://dreamkast.us.auth0.com/userinfo"
    ],
    "iat": 1662643742,
    "exp": 1663003742,
    "azp": "0cWWdpGt4CpWjHJ9QIHtPm5GrJLS25lz",
    "scope": "openid profile email"
  }')]
end

def alice_claim
  [JSON.parse('{
    "https://cloudnativedays.jp/roles": [
      "CNDT2022-Admin"
    ],
    "https://cloudnativedays.jp/userinfo": {
      "given_name": "Alice",
      "family_name": "alice",
      "nickname": "alice",
      "name": "alice",
      "picture": "https://alice.example.com",
      "locale": "en",
      "email": "alice@example.com",
      "email_verified": true
    },
    "iss": "https://dreamkast.us.auth0.com/",
    "sub": "google-oauth2|alice",
    "aud": [
      "https://event.cloudnativedays.jp/",
      "https://dreamkast.us.auth0.com/userinfo"
    ],
    "iat": 1662643742,
    "exp": 1663003742,
    "azp": "0cWWdpGt4CpWjHJ9QIHtPm5GrJLS25lz",
    "scope": "openid profile email"
  }')]
end
