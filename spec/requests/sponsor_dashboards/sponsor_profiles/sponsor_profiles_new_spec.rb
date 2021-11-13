require "rails_helper"

describe SponsorDashboards::SponsorProfilesController, type: :request do
  admin_userinfo = { userinfo: { info: { email: "alice@example.com" }, extra: { raw_info: { sub: "aaaa", "https://cloudnativedays.jp/roles" => ["CNDT2020-Admin"] } } } }
  describe "GET speaker_dashboards/:sponsor_id/sponsor_profiles#new" do
    let!(:cndt2020) { create(:cndt2020, :registered) }

    describe "user isn't sponsor's speaker" do
      let!(:sponsor) { create(:sponsor) }

      describe "sponsor profile isn't created yet" do
        describe "sponsor doesn't logged in" do
          it "returns a success response with sponsor login page" do
            get "/cndt2020/sponsor_dashboards/1/sponsor_profiles/new"
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status("302"))
            expect(response).to(redirect_to("/cndt2020/sponsor_dashboards/login"))
          end
        end

        describe "sponsor logged in" do
          before do
            allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(admin_userinfo))
          end

          it "returns a success response with new sponsor_profiles page" do
            get "/cndt2020/sponsor_dashboards/1/sponsor_profiles/new"
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status("302"))
            expect(response).to(redirect_to("/cndt2020/sponsor_dashboards/login"))
          end
        end
      end

      describe "sponsor profile is created" do
        let!(:sponsor) { create(:sponsor, :with_speaker_emails) }

        describe "sponsor doesn't logged in" do
          it "returns a success response with sponsor login page" do
            get "/cndt2020/sponsor_dashboards/1/sponsor_profiles/new"
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status("302"))
            expect(response).to(redirect_to("/cndt2020/sponsor_dashboards/login"))
          end
        end

        describe "sponsor logged in" do
          before do
            allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(admin_userinfo))
          end

          it "returns a success response with new sponsor_profiles page" do
            get "/cndt2020/sponsor_dashboards/1/sponsor_profiles/new"
            expect(response).to(be_successful)
            expect(response).to(have_http_status("200"))
            expect(response.body).to(include("\u30B9\u30DD\u30F3\u30B5\u30FC\u62C5\u5F53\u8005\u60C5\u5831\u30D5\u30A9\u30FC\u30E0(\u30B9\u30DD\u30F3\u30B5\u30FC1\u682A\u5F0F\u4F1A\u793E)"))
          end
        end
      end
    end
  end
end
