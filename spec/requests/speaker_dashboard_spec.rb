require 'rails_helper'

describe SpeakerDashboardsController, type: :request do
  admin_userinfo = {userinfo: {info: {email: "alice@example.com"}, extra: {raw_info: {sub: "aaaa", "https://cloudnativedays.jp/roles" => ["CNDT2020-Admin"]}}}}
  describe "GET speaker_dashboards#show" do
    context 'CNDT2020 is registered' do
      before do
        create(:cndt2020, :registered)
      end

      describe "speaker doesn't logged in" do
        it "returns a success response with speaker dashboard page" do
          get '/cndt2020/speaker_dashboard'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
          expect(response.body).to include 'スピーカーダッシュボード'
        end
      end

      describe 'speaker logged in' do
        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo)
        end

        describe "speaker doesn't registered" do
          it "returns a success response with event top page" do
            get '/cndt2020/speaker_dashboard'
            expect(response).to be_successful
            expect(response).to have_http_status '200'
            expect(response.body).to include 'スピーカーダッシュボード'
            expect(response.body).to include 'entry'
          end
        end

        describe 'speaker registered' do
          before do
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

    context 'CNDT2020 is registered and speaker entry is enabled' do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo)
        create(:cndt2020, :registered, :speaker_entry_enabled)
        create(:speaker_alice)
      end

      it "doesn't include information about video status" do
        get '/cndt2020/speaker_dashboard'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to_not include 'ビデオファイル提出状況'
        expect(response.body).to include 'edit'
      end
    end
  end
end
