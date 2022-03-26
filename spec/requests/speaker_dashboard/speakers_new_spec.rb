require 'rails_helper'

describe SpeakerDashboard::SpeakersController, type: :request do
  admin_userinfo = { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'aaaa', 'https://cloudnativedays.jp/roles' => ['CNDT2020-Admin'] } } } }
  describe 'GET speakers#new' do
    before do
      create(:cndt2020)
    end

    context "user doesn't log in" do
      context "user doesn't register" do
        it 'redirect to guidance' do
          get '/cndt2020/speaker_dashboard/speakers/new'
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to('/cndt2020/speakers/guidance'))
        end
      end

      context 'user already registered' do
        before do
          create(:speaker_alice)
          create(:speaker_bob)
        end

        context 'get new page' do
          it 'redirect to guidance' do
            get '/cndt2020/speaker_dashboard/speakers/new'
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to('/cndt2020/speakers/guidance'))
          end
        end
      end
    end

    context 'user already logged in' do
      context "user doesn't registered" do
        before do
          allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(admin_userinfo[:userinfo]))
          create(:speaker_bob)
        end

        context 'get new page' do
          it 'show entry form' do
            get '/cndt2020/speaker_dashboard/speakers/new'
            expect(response).to(be_successful)
            expect(response).to(have_http_status('200'))
          end
        end
      end

      describe 'user already registered' do
        before do
          allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(admin_userinfo[:userinfo]))
          create(:speaker_alice)
          create(:speaker_bob)
        end

        describe 'get new page' do
          it 'redirect to speaker dashboard' do
            get '/cndt2020/speaker_dashboard/speakers/new'
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to('/cndt2020/speaker_dashboard'))
          end
        end
      end
    end
  end

  describe 'GET speakers#guidance' do
    before { create(:cndt2020) }

    context "user doesn't log in" do
      it 'return success response' do
        get '/cndt2020/speakers/guidance'
        expect(response).to(be_successful)
        expect(response).to(have_http_status('200'))
      end
    end

    context 'user already logged in' do
      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(admin_userinfo[:userinfo]))
        create(:speaker_bob)
      end
      it 'return success response' do
        get '/cndt2020/speakers/guidance'
        expect(response).to(be_successful)
        expect(response).to(have_http_status('200'))
      end

      context 'from auth0' do
        it 'redirect to speaker form' do
          get '/cndt2020/speakers/guidance?state=state'
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to('/cndt2020/speakers/entry'))
        end
      end
    end
  end
end
