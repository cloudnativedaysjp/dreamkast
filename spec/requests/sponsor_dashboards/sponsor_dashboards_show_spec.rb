require 'rails_helper'

describe SponsorDashboards::SponsorDashboardsController, type: :request do
  admin_userinfo = {userinfo: {info: {email: "alice@example.com"}, extra: {raw_info: {sub: "aaaa", "https://cloudnativedays.jp/roles" => ["CNDT2020-Admin"]}}}}
  describe "GET sponsor_dashboards#show" do
    let!(:cndt2020) { create(:cndt2020, :registered) }

    describe "sponsor speaker isn't registered" do
      let!(:sponsor) { create(:sponsor)}

      describe "sponsor doesn't logged in" do
        it "redirects to sponsor login page" do
          get '/cndt2020/sponsor_dashboards/1'
          expect(response).to_not be_successful
          expect(response).to have_http_status '302'
          expect(response).to redirect_to('/cndt2020/sponsor_dashboards/login')
        end
      end

      describe "sponsor logged in and sponsor profile isn't created" do
        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo)
        end

        it "returns a forbidden response with 403 status code" do
          get '/cndt2020/sponsor_dashboards/1'
          expect(response).to_not be_successful
          expect(response).to have_http_status '302'
          expect(response).to redirect_to('/cndt2020/sponsor_dashboards/login')
        end
      end

      describe "sponsor logged in and sponsor profile isn created" do
        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo)
        end
        let!(:sponsor_alice) { create(:sponsor_alice) }

        it "returns a forbidden response with 403 status code" do
          get '/cndt2020/sponsor_dashboards/1'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
          expect(response.body).to include 'スポンサーダッシュボード'
        end
      end
    end
  end
end
