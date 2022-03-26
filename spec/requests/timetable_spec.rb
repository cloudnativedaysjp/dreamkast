require 'rails_helper'

describe TimetableController, type: :request do
  subject(:alice_session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'alice' } }, extra: { raw_info: { sub: 'alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  subject(:bob_session) { { userinfo: { info: { email: 'bob@example.com', extra: { sub: 'bob' } }, extra: { raw_info: { sub: 'bob', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  describe 'GET #index' do
    before do
      create(:rejekt, conference: conference)
      create(:talk_category1)
      create(:talk_difficulties1)
    end

    let!(:conference) { create(:cndt2020) }
    let!(:talk1) { create(:talk1) }
    let!(:talk2) { create(:talk2) }
    let!(:talk_rejekt) { create(:talk_rejekt) }
    let!(:cm) { create(:talk_cm) }

    describe 'not logged in' do
      context "get exists event's timetables" do
        it 'returns a success response without form' do
          get '/cndt2020/timetables'
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
          expect(response.body).to_not(include('<form action="profiles/talks"'))
          expect(response.body).to(include(talk1.title))
          expect(response.body).to(include(talk2.title))
          expect(response.body).to_not(include(talk_rejekt.title))
          expect(response.body).to_not(include(cm.title))
        end
      end

      context "get not exists event's timetables" do
        it 'returns not found response' do
          get '/not_found/timetables'
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('404'))
        end
      end
    end

    describe 'logged in and not registered' do
      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return({ info: { email: 'alice@example.com' } }))
      end

      it 'redirect to /cndt2020/registration' do
        get '/cndt2020/timetables'
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/cndt2020/registration'))
      end
    end

    describe 'logged in' do
      before do
        create(:alice, :on_cndt2020)
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(alice_session[:userinfo]))
      end

      context "get exists event's timetables" do
        it 'returns a success response with form' do
          get '/cndt2020/timetables'
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
          expect(response.body).to(include('<form action="profiles/talks"'))
          expect(response.body).to(include(talk1.title))
          expect(response.body).to(include(talk2.title))
          expect(response.body).to_not(include(talk_rejekt.title))
        end
      end


      context "get not exists event's timetables" do
        it 'returns not found response' do
          get '/not_found/timetables'
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('404'))
        end
      end
    end
  end

  describe 'GET cndo#index' do
    before do
      create(:cndo2021)
      create(:cndo_talk_category1)
      create(:cndo_talk_difficulties1)
    end

    let!(:cndo_talk1) { create(:cndo_talk1) }
    let!(:cndo_talk2) { create(:cndo_talk2) }

    describe 'not logged in' do
      context "get exists event's timetables" do
        it 'returns a success response without form' do
          get '/cndo2021/timetables'
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
          expect(response.body).to_not(include('<form action="profiles/talks"'))
          expect(response.body).to(include(cndo_talk1.title))
          expect(response.body).to(include(cndo_talk2.title))
        end
      end
    end

    describe 'logged in and not registered' do
      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return({ info: { email: 'alice@example.com' } }))
      end

      it 'redirect to /cndo2021/registration' do
        get '/cndo2021/timetables'
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/cndo2021/registration'))
      end
    end

    describe 'logged in' do
      before do
        create(:bob, :on_cndo2021)
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(bob_session[:userinfo]))
      end

      context "get exists event's timetables" do
        it 'returns a success response with form' do
          get '/cndo2021/timetables'
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
          expect(response.body).to(include('<form action="profiles/talks"'))
          expect(response.body).to(include(cndo_talk1.title))
          expect(response.body).to(include(cndo_talk2.title))
        end
      end
    end
  end
end
