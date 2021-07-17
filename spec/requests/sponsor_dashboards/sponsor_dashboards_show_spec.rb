require 'rails_helper'

describe SponsorDashboards::SponsorDashboardsController, type: :request do
  admin_userinfo = {userinfo: {info: {email: "alice@example.com"}, extra: {raw_info: {sub: "aaaa", "https://cloudnativedays.jp/roles" => ["CNDT2020-Admin"]}}}}
  describe "GET sponsor_dashboards#show" do
    let!(:cndt2020) { create(:cndt2020, :registered) }

    shared_examples_for :redirect_to_login_page do
      it "redirect to login page" do
        get '/cndt2020/sponsor_dashboards/1'
        expect(response).to_not be_successful
        expect(response).to have_http_status '302'
        expect(response).to redirect_to('/cndt2020/sponsor_dashboards/login')
      end
    end

    describe "user isn't sponsor's speaker" do
      let!(:sponsor) { create(:sponsor)}

      describe "sponsor profile isn't created yet" do
        describe "sponsor doesn't logged in" do
          it_should_behave_like :redirect_to_login_page
        end

        describe "sponsor logged in" do
          before { allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo) }

          it_should_behave_like :redirect_to_login_page
        end
      end
    end

    describe "user is sponsor's speaker" do
      let!(:sponsor) { create(:sponsor)}

      describe "sponsor profile isn't created yet" do
        describe "sponsor doesn't logged in" do
          it_should_behave_like :redirect_to_login_page
        end

        describe "sponsor logged in" do
          before { allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo) }

          it_should_behave_like :redirect_to_login_page
        end
      end

      describe "sponsor profile is already created" do
        let!(:sponsor_alice) { create(:sponsor_alice) }

        describe "sponsor doesn't logged in" do
          it_should_behave_like :redirect_to_login_page
        end

        describe "sponsor logged in" do
          before { allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(admin_userinfo) }

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
end
