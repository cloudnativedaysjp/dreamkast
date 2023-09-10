require 'rails_helper'

describe Admin::SpeakersController, type: :request do
  subject(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'alice' } }, extra: { raw_info: { sub: 'alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { ['CNDT2020-Admin'] }

  before do
    conference = create(:cndt2020)
    create(:streaming, status: 'created', conference:, track: conference.tracks.first)
  end

  context 'user logged in' do
    before do
      ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
      allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
        if arg[1] == :userinfo
          session[:userinfo]
        else
          arg[0].send(:original, arg[1])
        end
      end)
    end

    describe 'GET :event/admin/streamings#index' do
      it 'returns a success response' do
        get admin_streamings_path(event: 'cndt2020')
        expect(response).to(be_successful)
        expect(response).to(have_http_status('200'))
      end

      it 'returns a success response with streams' do
        get admin_streamings_path(event: 'cndt2020')
        expect(response).to(be_successful)
        expect(response).to(have_http_status('200'))

        expect(response.body).to(include('created'))
      end
    end
  end
end
