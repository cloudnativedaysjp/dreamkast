require "rails_helper"

RSpec.describe(TracksController, type: :request) do
  subject(:session) { { userinfo: { info: { email: "alice@example.com", extra: { sub: "aaa" } }, extra: { raw_info: { sub: "aaa", "https://cloudnativedays.jp/roles" => roles } } } } }
  let(:roles) { [] }

  describe "GET /:event/dashboard" do
    describe "logged in and registered" do
      before do
        create(:cndt2020)
        create(:alice, :on_cndt2020)
        allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
      end

      context "user is admin" do
        let(:roles) { ["CNDT2020-Admin"] }

        it "return a success response" do
          get "/cndt2020/dashboard"
          expect(response).to(be_successful)
          expect(response).to(have_http_status("200"))
        end

        it "link to admin is displayed" do
          get "/cndt2020/dashboard"
          expect(response.body).to(include('<a class="dropdown-item" href="/cndt2020/admin">管理画面</a>'))
        end

        context "user is speaker" do
          before do
            @alice = create(:speaker_alice)
          end
          it "exists speaker" do
            get "/cndt2020/dashboard"
            expect(response).to(be_successful)
            expect(controller.instance_variable_get("@speaker").name).to(eq("Alice"))
          end

          context "wnen announcement is not published" do
            before do
              create(:speaker_announcement, :cndt2020, speakers: [@alice])
            end
            it "not exists speaker_announcements" do
              get "/cndt2020/dashboard"
              expect(response).to(be_successful)
              expect(controller.instance_variable_get("@speaker_announcements").size).to(eq(0))
            end
          end

          context "when announcement is published" do
            before do
              create(:speaker_announcement, :cndt2020, :published, speakers: [@alice])
            end
            it "exists speaker_announcements" do
              get "/cndt2020/dashboard"
              expect(response).to(be_successful)
              expect(controller.instance_variable_get("@speaker_announcements").size).to(eq(1))
            end
          end
        end
      end

      context "user is not admin" do
        it "return a success response" do
          get "/cndt2020/dashboard"
          expect(response).to(be_successful)
          expect(response).to(have_http_status("200"))
        end

        it "link to admin is not displayed" do
          get "/cndt2020/dashboard"
          expect(response.body).to_not(include('<a class="dropdown-item" href="/admin">管理画面</a>'))
        end
      end

      context "get not exists event's dashboard" do
        it "returns not found response" do
          get "/not_found/dashboard"
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status("404"))
        end
      end
    end

    describe "not logged in" do
      before do
        create(:cndt2020)
      end

      context "get exists event's dashboard" do
        it "redirect to top page a success response" do
          get "/cndt2020/dashboard"
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status("302"))
          expect(response).to(redirect_to("/cndt2020"))
        end
      end

      context "get not exists event's dashboard" do
        it "redirect to top page a success response" do
          get "/not_found/dashboard"
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status("404"))
        end
      end
    end
  end

  describe "GET /:event/tracks" do
    describe "logged in and registered" do
      before do
        create(:cndt2020, :opened)
        create(:alice, :on_cndt2020)
        allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
      end

      context "when user access to dashboard" do
        it "return a success response" do
          get "/cndt2020/tracks"
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status("302"))
          expect(response).to(redirect_to("/cndt2020/ui/"))
        end
      end

      context "when user access to root page" do
        it "redirect to tracks" do
          get "/cndt2020"
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status("302"))
          expect(response).to(redirect_to("/cndt2020/dashboard"))
        end
      end
    end

    describe "not logged in" do
      before do
        create(:cndt2020)
      end

      context "get exists event's dashboard" do
        it "redirect to top page a success response" do
          get "/cndt2020/tracks"
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status("302"))
          expect(response).to(redirect_to("/cndt2020"))
        end
      end
    end
  end
end
