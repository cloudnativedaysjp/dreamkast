require 'rails_helper'

describe SpeakerDashboardsController, type: :request do
  admin_userinfo = {userinfo: {info: {email: "foo@example.com"}, extra: {raw_info: {sub: "aaaa", "https://cloudnativedays.jp/roles" => ["CNDT2020-Admin"]}}}}
  describe "GET speaker_dashboards#show" do
    before do
      create(:cndt2020)
      create(:day1)
      create(:day2)
    end

    describe 'not logged in' do
      it "returns a success response with speaker dashboard page" do
        get '/cndt2020/speaker_dashboard'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include 'スピーカーダッシュボード'
      end
    end

    describe 'logged in' do
      describe 'not registered' do
        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo)
        end

        it "returns a success response with event top page" do
          get '/cndt2020/speaker_dashboard'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
          expect(response.body).to include 'スピーカーダッシュボード'
          expect(response.body).to include 'entry'
        end
      end

      describe 'registered' do
        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo)
          create(:speaker_alice)
        end

        it "returns a success response with event top page" do
          get '/cndt2020/speaker_dashboard'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
          expect(response.body).to include 'スピーカーダッシュボード'
          expect(response.body).to include 'edit'
        end
      end
    end
  end
end
