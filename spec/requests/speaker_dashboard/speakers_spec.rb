require 'rails_helper'

describe SpeakerDashboard::SpeakersController, type: :request do
  admin_userinfo = {userinfo: {info: {email: "foo@example.com"}, extra: {raw_info: {sub: "aaaa", "https://cloudnativedays.jp/roles" => ["CNDT2020-Admin"]}}}}
  describe "GET speakers#edit" do
    before do
      create(:cndt2020)
      create(:day1)
      create(:day2)
    end

    context "user doesn't log in" do
      context "user doesn't register" do
        context "get anyone's edit page" do
          it "redirect to speaker_dashboard" do
            get '/cndt2020/speaker_dashboard/speakers/1/edit'
            expect(response).to_not be_successful
            expect(response).to have_http_status '302'
            expect(response).to redirect_to('/cndt2020/speaker_dashboard')
          end
        end
      end

      context 'user already registered' do
        before do
          create(:speaker_alice)
          create(:speaker_bob)
        end

        context 'get my edit page' do
          it "redirect to speaker_dashboard" do
            get '/cndt2020/speaker_dashboard/speakers/1/edit'
            expect(response).to_not be_successful
            expect(response).to have_http_status '302'
            expect(response).to redirect_to('/cndt2020/speaker_dashboard')
          end
        end

        context "get other's edit page" do
          it "redirect to speaker_dashboard" do
            get '/cndt2020/speaker_dashboard/speakers/2/edit'
            expect(response).to_not be_successful
            expect(response).to have_http_status '302'
            expect(response).to redirect_to('/cndt2020/speaker_dashboard')
          end
        end
      end
    end

    context "user already logged in" do
      context "user doesn't registered" do
        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo)
          create(:speaker_bob)
        end

        context 'get others edit page' do
          it "returns a 403" do
            get '/cndt2020/speaker_dashboard/speakers/2/edit'
            expect(response).to_not be_successful
            expect(response).to have_http_status '403'
          end
        end
      end

      describe 'user already registered' do
        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo)
          create(:speaker_alice)
          create(:speaker_bob)
        end

        describe 'get my edit page' do
          it "returns a success response with event top page" do
            get '/cndt2020/speaker_dashboard/speakers/1/edit'
            expect(response).to be_successful
            expect(response).to have_http_status '200'
          end
        end

        describe 'get others edit page' do
          it "return 403" do
            get '/cndt2020/speaker_dashboard/speakers/2/edit'
            expect(response).to_not be_successful
            expect(response).to have_http_status '403'
          end
        end
      end
    end
  end
end
