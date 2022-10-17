require 'rails_helper'

describe OrdersController, type: :request do
  describe 'GET /cndt2020/orders/new' do
    let!(:cndt2020) { create(:cndt2020) }

    describe 'not logged in' do
      it 'redirect to event top page' do
        get '/cndt2020/orders/new'
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/cndt2020'))
      end
    end

    describe 'logged in and not registered' do
      subject(:user_session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'mock', 'https://cloudnativedays.jp/roles' => '' } } } } }

      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(user_session[:userinfo]))
      end

      it 'redirect to registration page' do
        get '/cndt2020/orders/new'
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/cndt2020/registration'))
      end
    end

    describe 'logged in and registered and not ordered' do
      subject(:user_session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'mock', 'https://cloudnativedays.jp/roles' => '' } } } } }

      before do
        create(:alice, conference: cndt2020)
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(user_session[:userinfo]))
      end

      it 'display order page' do
        get '/cndt2020/orders/new'
        expect(response).to(be_successful)
        expect(response).to(have_http_status('200'))
        expect(response.body).to(include('参加方式'))
      end
    end
  end

  describe 'POST /cndt2020/orders' do
    let(:cndt2020) { create(:cndt2020) }
    let(:ticket_a) { create(:ticket, :a, conference: cndt2020) }
    let(:ticket_b) { create(:ticket, :b, conference: cndt2020) }

    describe 'not logged in' do
      it 'redirect to event top page' do
        post '/cndt2020/orders', params: { order: { ticket_ids: [ticket_a.id] } }
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/cndt2020'))
      end
    end

    describe 'logged in and not registered' do
      subject(:user_session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'mock', 'https://cloudnativedays.jp/roles' => '' } } } } }

      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(user_session[:userinfo]))
      end

      it 'redirect to registration page' do
        post '/cndt2020/orders', params: { order: { ticket_ids: [ticket_a.id] } }
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/cndt2020/registration'))
      end
    end

    describe 'logged in and registered' do
      subject(:user_session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'mock', 'https://cloudnativedays.jp/roles' => '' } } } } }
      let!(:alice) { create(:alice, conference: cndt2020) }

      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(user_session[:userinfo]))
      end

      it 'success to create order' do
        post '/cndt2020/orders', params: { order: { ticket_ids: ticket_a.id } }
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/cndt2020/timetables'))
        expect(alice.orders.size).to(eq(1))
      end
    end
  end
end
