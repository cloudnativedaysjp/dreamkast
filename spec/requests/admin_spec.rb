require "rails_helper"

describe AdminController, type: :request do
  subject(:session) { { userinfo: { info: { email: "alice@example.com", extra: { sub: "alice" } }, extra: { raw_info: { sub: "alice", "https://cloudnativedays.jp/roles" => roles } } } } }
  let(:roles) { [] }

  before do
    create(:cndt2020)
  end

  describe "GET admin#show" do
    context "user doesn't logged in" do
      it "redirect to event top page" do
        get admin_path(event: "cndt2020")
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status("302"))
        expect(response).to(redirect_to("/cndt2020"))
      end
    end

    context "user logged in" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
      end

      context "user is not registered" do
        it "redirect to //registration" do
          skip "TODO: `//registration` \u306B\u30EA\u30C0\u30A4\u30EC\u30AF\u30C8\u3055\u308C\u3066\u540D\u524D\u89E3\u6C7A\u3067\u304D\u305A\u306B\u30A8\u30E9\u30FC\u306B\u306A\u308B\u306E\u3067\u4FEE\u6B63\u304C\u5FC5\u8981"
          get admin_path(event: "cndt2020")
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status("302"))
          expect(response).to(redirect_to("//registration"))
        end
      end

      context "user is registered" do
        before do
          create(:alice, :on_cndt2020)
        end

        context "user is admin" do
          let(:roles) { ["CNDT2020-Admin"] }

          it "returns a success response" do
            get admin_path(event: "cndt2020")
            expect(response).to(be_successful)
            expect(response).to(have_http_status("200"))
          end
        end

        context "user is not admin" do
          it "returns a success response" do
            get admin_path(event: "cndt2020")
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status("403"))
          end
        end
      end
    end
  end

  describe "GET admin#users" do
    context "user doesn't logged in" do
      it "redirect to event top page" do
        get admin_users_path(event: "cndt2020")
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status("302"))
        expect(response).to(redirect_to("/cndt2020"))
      end
    end

    context "user logged in" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
      end

      context "user is not registered" do
        it "redirect to //registration" do
          skip "TODO: `//registration` \u306B\u30EA\u30C0\u30A4\u30EC\u30AF\u30C8\u3055\u308C\u3066\u540D\u524D\u89E3\u6C7A\u3067\u304D\u305A\u306B\u30A8\u30E9\u30FC\u306B\u306A\u308B\u306E\u3067\u4FEE\u6B63\u304C\u5FC5\u8981"
          get "/admin/users"
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status("302"))
          expect(response).to(redirect_to("//registration"))
        end
      end

      context "user is registered" do
        before do
          create(:alice, :on_cndt2020)
        end

        context "user is admin" do
          let(:roles) { ["CNDT2020-Admin"] }

          it "returns a success response" do
            get admin_users_path(event: "cndt2020")
            expect(response).to(be_successful)
            expect(response).to(have_http_status("200"))
          end
        end

        context "user is not admin" do
          it "returns a success response" do
            get admin_users_path(event: "cndt2020")
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status("403"))
          end
        end
      end
    end
  end
end
