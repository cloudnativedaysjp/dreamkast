require 'rails_helper'

describe ProfilesController, type: :request do
  describe 'GET /registration' do
    before do
      create(:cndt2020)
    end

    describe 'not logged in' do
      it 'redirect to event top page' do
        get '/cndt2020/registration'
        expect(response).to(be_successful)
        expect(response).to(have_http_status('200'))
        expect(response.body).to(include('ログイン'))
      end
    end

    describe 'logged in and not registered' do
      subject(:user_session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'mock', 'https://cloudnativedays.jp/roles' => '' } } } } }

      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(user_session[:userinfo]))
      end

      it "doesn't have timetable and speakers links" do
        get '/cndt2020/registration'
        expect(response).to(be_successful)
        expect(response).to(have_http_status('200'))
        expect(response.body).to_not(include('Timetable'))
      end
    end

    describe 'logged in and already registered' do
      subject(:user_session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'mock', 'https://cloudnativedays.jp/roles' => '' } } } } }

      before do
        create(:alice, :on_cndt2020)
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(user_session[:userinfo]))
      end

      it 'redirect to timetables' do
        get '/cndt2020/registration'
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response.body).to(redirect_to('/cndt2020/order_ticket'))
      end
    end

    describe 'register' do
      subject(:user_session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'aaa', 'https://cloudnativedays.jp/roles' => '' } } } } }
      subject(:profiles_params)  do
        attributes_for(:alice)
      end
      subject(:agreement_params) do
        {
          require_email: '1',
          require_tel: '1',
          require_posting: '1',
          agree_ms: '1',
        }
      end

      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(user_session[:userinfo]))
        create(:form_item1)
        create(:form_item2)
        create(:form_item3)
        create(:form_item4)
      end

      it 'is created 4 agreements when user select 4 checkbox' do
        expect do
          post('/cndt2020/profiles', params: { profile: profiles_params.merge(agreement_params) })
        end.to(change(Agreement, :count).by(+4))
        expect(response.body).to(redirect_to('/cndt2020/order_ticket'))
      end
    end
  end
end
