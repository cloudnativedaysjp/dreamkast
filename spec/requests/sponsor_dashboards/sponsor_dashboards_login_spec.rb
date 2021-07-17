require 'rails_helper'

describe SponsorDashboards::SponsorDashboardsController, type: :request do
  admin_userinfo = {userinfo: {info: {email: "alice@example.com"}, extra: {raw_info: {sub: "aaaa", "https://cloudnativedays.jp/roles" => ["CNDT2020-Admin"]}}}}
  describe "GET speaker_dashboards#login" do
    let!(:cndt2020) { create(:cndt2020, :registered) }

    describe "sponsor speaker isn't registered" do
      let!(:sponsor) { create(:sponsor)}

      describe "sponsor doesn't logged in" do
        it "returns a success response with sponsor login page" do
          get '/cndt2020/sponsor_dashboards/login'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
          expect(response.body).to include 'スポンサーダッシュボードへログインする'
        end
      end

      describe "sponsor logged in" do
        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo)
        end

        it "returns a forbidden response with 403 status code" do
          get '/cndt2020/sponsor_dashboards/login'
          expect(response).to_not be_successful
          expect(response).to have_http_status '403'
        end
      end
    end

    describe "sponsor speaker is registered" do
      let!(:sponsor) { create(:sponsor, :with_speaker_emails)}

      describe "sponsor doesn't logged in" do
        it "returns a success response with sponsor login page" do
          get '/cndt2020/sponsor_dashboards/login'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
          expect(response.body).to include 'スポンサーダッシュボードへログインする'
        end
      end

      describe "sponsor logged in and sponsor profile isn't created" do
        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo)
        end

        it "redirects to creating sponsor_profile page" do
          get "/cndt2020/sponsor_dashboards/login"
          expect(response).to_not be_successful
          expect(response).to have_http_status '302'
          expect(response).to redirect_to('/cndt2020/sponsor_dashboards/1/sponsor_profiles/new')
        end
      end

      describe "sponsor logged in and sponsor profile isn't created" do
        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo)
        end
        let!(:sponsor_alice) { create(:sponsor_alice) }

        it "redirects to sponsor_dashboards" do
          get "/cndt2020/sponsor_dashboards/login"
          expect(response).to_not be_successful
          expect(response).to have_http_status '302'
          expect(response).to redirect_to('/cndt2020/sponsor_dashboards/1')
        end
      end
    end
  end
end
