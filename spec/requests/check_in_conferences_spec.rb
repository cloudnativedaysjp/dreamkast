require 'rails_helper'

RSpec.describe(CheckInConferencesController, type: :request) do
  let!(:cndt2020) { create(:cndt2020) }
  let!(:session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  describe 'GET /:event/self_check_in' do
    context 'when not logged in' do
      it 'redirects to login page' do
        get '/cndt2020/self_check_in'
        expect(response).to(have_http_status('200'))
        expect(response.body).to(include('セルフチェックインにはログインが必要です'))
      end
    end

    context 'when logged in and has profile' do
      before do
        create(:alice, :on_cndt2020)
        ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
          if arg[1] == :userinfo
            session[:userinfo]
          else
            arg[0].send(:original, arg[1])
          end
        end)
      end

      it 'creates a check-in record' do
        expect {
          get('/cndt2020/self_check_in')
        }.to(change(CheckInConference, :count).by(1))

        expect(response).to(have_http_status(:ok))

        check_in = CheckInConference.last
        expect(check_in.conference_id).to(eq(cndt2020.id))
        user = User.find_by(email: 'alice@example.com')
        profile = Profile.find_by(user_id: user.id, conference_id: cndt2020.id)
        expect(check_in.profile_id).to(eq(profile.id))
        expect(check_in.check_in_timestamp).to(be_present)
      end
    end

    context 'when logged in but no profile' do
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

      it 'redirects to registration page with alert' do
        get '/cndt2020/self_check_in'
        expect(response).to(redirect_to('/cndt2020/registration'))
        expect(flash[:alert]).to(eq('チェックインするためには参加登録が必要です。登録後、再度スキャンしてチェックインしてください。'))
      end
    end
  end
end
