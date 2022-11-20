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
        expect(response.body).to(redirect_to('/cndt2020/orders/new'))
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
        expect(response.body).to(redirect_to('/cndt2020/orders/new'))
      end
    end
  end

  describe 'GET /cndt2020/profiles/checkin/:ticket_id without profile' do
    subject(:user_session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'mock', 'https://cloudnativedays.jp/roles' => '' } } } } }
    let(:ticket_online) { create(:ticket, :online, conference: cndt2020) }
    let(:ticket_a) { create(:ticket, :online, conference: cndt2020) }

    before do
      allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(user_session[:userinfo]))
    end

    context 'GET /profiles/checkin/:id' do
      context 'when ticket_id is valid' do
        it 'should redirect to registration' do
          get "/cndt2020/profiles/checkin/#{ticket_online.id}"
          expect(response).to(redirect_to('/cndt2020/registration'))
        end
      end
    end
  end

  describe 'GET /cndt2020/profiles/checkin/:ticket_id' do
    subject(:user_session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'mock', 'https://cloudnativedays.jp/roles' => '' } } } } }
    let(:alice) { create(:alice, conference: cndt2020) }
    let(:ticket_online) { create(:ticket, :online, conference: cndt2020) }
    let(:ticket_a) { create(:ticket, :online, conference: cndt2020) }
    let!(:order) { create(:order, profile: alice) }

    before do
      allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(user_session[:userinfo]))
    end

    context 'GET /profiles/checkin/:id' do
      context 'when ticket_id is not exist' do
        it 'should redirect to dashboard' do
          get '/cndt2020/profiles/checkin/hoge'
          expect(response).to(redirect_to('/cndt2020/dashboard'))
        end
      end

      context 'when ticket_id is valid' do
        it 'should have checkin' do
          get "/cndt2020/profiles/checkin/#{ticket_online.id}"
          expect(response).to(be_successful)
          expect(CheckIn.find_by(profile_id: alice.id)).to(be_present)
        end
      end

      context 'user already checked-in' do
        let!(:checkin) { create(:check_in, profile_id: alice.id, ticket_id: ticket_online.id, order_id: order.id) }
        it 'should redirect to dashboard' do
          get "/cndt2020/profiles/checkin/#{ticket_online.id}"
          expect(response).to(redirect_to('/cndt2020/dashboard'))
        end
      end
    end
  end
end
