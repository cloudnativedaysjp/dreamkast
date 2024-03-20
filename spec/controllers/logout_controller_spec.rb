require 'rails_helper'

RSpec.describe(LogoutController, type: :controller) do
  describe 'GET #logout' do
    around do |example|
      original = ENV.to_h
      ENV['AUTH0_DOMAIN'] = 'example.com'
      ENV['AUTH0_CLIENT_ID'] = 'auth0_client_id'

      example.run
    ensure
      ENV.replace(original)
    end

    it 'redirects to Auth0 logout URL' do
      get :logout
      expect(response).to(redirect_to('https://example.com/v2/logout?returnTo=http%3A%2F%2Ftest.host%2F&client_id=auth0_client_id'))
    end

    it 'calls reset_session' do
      allow(controller).to(receive(:reset_session).and_call_original)

      get :logout
      expect(controller).to(have_received(:reset_session))
    end
  end
end
