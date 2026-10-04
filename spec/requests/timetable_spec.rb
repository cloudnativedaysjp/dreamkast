require 'rails_helper'

describe TimetableController, type: :request do
  subject(:alice_session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  subject(:bob_session) { { userinfo: { info: { email: 'bob@example.com' }, extra: { raw_info: { sub: 'google-oauth2|bob', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  describe 'GET #index' do
    before do
      create(:rejekt, conference:)
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
          expect(response.body).to_not(include('<form action="/cndt2020/profiles/talks"'))
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
        create(:alice, conference:)
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(alice_session[:userinfo]))
      end

      context "get exists event's timetables" do
        it 'returns a success response with form' do
          get '/cndt2020/timetables'
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
          expect(response.body).to(include('<form action="/cndt2020/profiles/talks"'))
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
    let!(:cndo2021) { create(:cndo2021) }
    before do
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
          expect(response.body).to_not(include('<form action="/cndo2021/profiles/talks"'))
          expect(response.body).to(include(cndo_talk1.title))
          expect(response.body).to(include(cndo_talk2.title))
        end
      end
    end

    describe 'logged in and not registered' do
      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(alice_session[:userinfo]))
      end

      context 'when conference status is archived' do
        before { Conference.find_by(abbr: 'cndo2021').update!(conference_status: Conference::STATUS_ARCHIVED) }
        it 'access to /cndo2021/timetables' do
          get '/cndo2021/timetables'
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
        end
      end

      context 'when conference status is not archived' do
        it 'redirect to /cndo2021/registration' do
          get '/cndo2021/timetables'
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to('/cndo2021/registration'))
        end
      end
    end

    describe 'logged in' do
      before do
        create(:bob, conference: cndo2021)
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(bob_session[:userinfo]))
      end

      context "get exists event's timetables" do
        it 'returns a success response with form' do
          get '/cndo2021/timetables'
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
          expect(response.body).to(include('<form action="/cndo2021/profiles/talks"'))
          expect(response.body).to(include(cndo_talk1.title))
          expect(response.body).to(include(cndo_talk2.title))
        end
      end
    end
  end

  describe 'GET cndw2026#index' do
    let!(:cndw2026) { create(:cndw2026) }
    let(:conference_day) { cndw2026.conference_days.order(:date).first }
    let!(:talks) do
      cndw2026.tracks.order(:number).map do |track|
        create(:talk, conference: cndw2026, conference_day:, track:, title: "Track #{track.name} のセッション",
                      start_time: '10:00', end_time: '10:40', show_on_timetable: true)
      end
    end

    describe 'not logged in' do
      it '4トラック分の見出しとセッションをフォームなしで表示する' do
        get '/cndw2026/timetables'
        expect(response).to(have_http_status('200'))
        expect(response.body).to_not(include('<form action="/cndw2026/profiles/talks"'))
        %w[A B C D].each { |name| expect(response.body).to(include("Track #{name}")) }
        talks.each { |talk| expect(response.body).to(include(talk.title)) }
        expect(response.body).to(include('grid-template-columns: 4rem repeat(4, minmax(0, 1fr));'))
        expect(response.body).to_not(include('Platform Engineering Track'))
        expect(response.body).to_not(include('残席'))
        expect(response.body).to(include('id="is_offline" value="false"'))

        day1, day2 = response.body.split('id="timetable-day-2"')
        expect(day1).to(include('懇親会'))
        expect(day1).to_not(include('クロージング'))
        expect(day2).to(include('クロージング'))
      end
    end

    describe 'logged in' do
      before do
        create(:alice, conference: cndw2026)
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(alice_session[:userinfo]))
      end

      it 'セッション選択用のチェックボックスを表示する' do
        get '/cndw2026/timetables'
        expect(response).to(have_http_status('200'))
        expect(response.body).to(include('<form action="/cndw2026/profiles/talks"'))
        talks.each { |talk| expect(response.body).to(include("name=\"talks[#{talk.id}]\"")) }
        expect(response.body).to(include('セッション登録'))
        expect(response.body.scan('type="checkbox"').size).to(eq(talks.size))
      end
    end
  end
end
