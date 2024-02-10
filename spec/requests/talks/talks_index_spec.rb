require 'rails_helper'

describe TalksController, type: :request do
  subject(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'aaa' } }, extra: { raw_info: { sub: 'aaa', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  describe 'GET /cndt2020/talks' do
    let!(:userinfo) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { 'https://cloudnativedays.jp/roles' => 'CNDT2020-Admin', sub: '' } } } } }

    context 'CNDT2020 is migrated' do
      let!(:cndt2020) { create(:cndt2020, :migrated) }

      it 'redirect to website' do
        get '/cndt2020/talks'
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('https://cloudnativedays.jp/cndt2020'))
      end
    end

    context 'CNDT2020 is registered' do
      before { create(:cndt2020, :registered) }

      context "user doesn't logged in" do
        it 'returns a success response' do
          get '/cndt2020/talks'
          expect(response).to(be_successful)
        end
      end

      context "user doesn't registered" do
        before {
          allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
        }
        it 'redirect to /cndt2020/registration' do
          get '/cndt2020/talks'
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to('/cndt2020/registration'))
        end

        context 'when user is registered as speaker' do
          before { create(:speaker_alice) }
          it 'returns a success response' do
            get '/cndt2020/talks'
            expect(response).to(be_successful)
          end
        end
      end
    end

    context 'CNDT2020 is opened' do
      before  { create(:cndt2020, :opened) }
      context "user doesn't registered" do
        before {
          allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
        }
        it 'redirect to /cndt2020/registration' do
          get '/cndt2020/talks'
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to('/cndt2020/registration'))
        end

        context 'when user is registered as speaker' do
          before { create(:speaker_alice) }
          it 'redirect to /cndt2020/registration' do
            get '/cndt2020/talks'
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to('/cndt2020/registration'))
          end
        end
      end
    end
  end
end
