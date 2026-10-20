require 'rails_helper'

RSpec.describe('Attendee dashboard projects', type: :request) do
  subject(:session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => [] } } } } }

  describe 'GET /cndw2026/dashboard' do
    before do
      cndw2026 = create(:cndw2026)
      create(:alice, conference: cndw2026)
      allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
    end

    it 'shows the project list with a link to the hands-on page' do
      get '/cndw2026/dashboard'
      expect(response).to(have_http_status('200'))
      expect(response.body).to(include('企画一覧'))
      expect(response.body).to(include('href="/cndw2026/hands-on"'))
    end
  end
end
