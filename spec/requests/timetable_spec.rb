require 'rails_helper'

describe TimetableController, type: :request do
  subject(:session) { {userinfo: {info: {email: "foo@example.com", extra: {sub: "aaa"}}, extra: {raw_info: {sub: "aaa", "https://cloudnativedays.jp/roles" => roles}}} } }
  let(:roles) { [] }

  describe "GET #index" do
    before do
      create(:cndt2020)
      create(:day1)
      create(:day2)
      create(:rejekt)
      create(:track1)
      create(:track2)
      create(:track3)
      create(:track4)
      create(:track5)
      create(:track6)
      create(:talk_category1)
      create(:talk_difficulties1)
    end

    let!(:talk1) { create(:talk1) }
    let!(:talk2) { create(:talk2) }
    let!(:talk_rejekt) { create(:talk_rejekt) }
    let!(:cm) { create(:talk_cm) }

    describe 'not logged in' do
      context 'get exists event\'s timetables' do
        it "returns a success response without form" do
          get '/cndt2020/timetables'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
          expect(response.body).to_not include '<form action="profiles/talks"'
          expect(response.body).to include talk1.title
          expect(response.body).to include talk2.title
          expect(response.body).to_not include talk_rejekt.title
          expect(response.body).to_not include cm.title
        end
      end

      context 'get not exists event\'s timetables' do
        it "returns not found response" do
          get '/not_found/timetables'
          expect(response).to_not be_successful
          expect(response).to have_http_status '404'
        end
      end
    end

    describe 'logged in and not registerd' do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "foo@example.com"}})
      end

      it "redirect to /cndt2020/registration" do
        get '/cndt2020/timetables'
        expect(response).to_not be_successful
        expect(response).to have_http_status '302'
        expect(response).to redirect_to '/cndt2020/registration'
      end
    end

    describe 'logged in' do
      before do
        create(:alice)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
      end

      context 'get exists event\'s timetables' do
        it "returns a success response with form" do
          get '/cndt2020/timetables'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
          expect(response.body).to include '<form action="profiles/talks"'
          expect(response.body).to include talk1.title
          expect(response.body).to include talk2.title
          expect(response.body).to_not include talk_rejekt.title
        end
      end


      context 'get not exists event\'s timetables' do
        it "returns not found response" do
          get '/not_found/timetables'
          expect(response).to_not be_successful
          expect(response).to have_http_status '404'
        end
      end
    end
  end
end
