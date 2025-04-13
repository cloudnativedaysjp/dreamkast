require 'rails_helper'

describe ProfilesController, type: :request do
  let!(:cndt2020) { create(:cndt2020) }
  describe 'GET /registration' do
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
        ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
          if arg[1] == :userinfo
            user_session[:userinfo]
          else
            arg[0].send(:original, arg[1])
          end
        end)
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

      it 'redirect to dashboard' do
        get '/cndt2020/registration'
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response.body).to(redirect_to('/cndt2020/dashboard'))
      end
    end

    describe 'register' do
      subject(:user_session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'aaa', 'https://cloudnativedays.jp/roles' => '' } } } } }
      subject(:profiles_params)  do
        attributes_for(:alice)
      end

      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(user_session[:userinfo]))
        create(:form_item1)
        create(:form_item2)
        create(:form_item3)
        create(:form_item4)
      end
    end
  end
end
