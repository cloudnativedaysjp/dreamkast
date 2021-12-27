require "rails_helper"

describe EventController, type: :request do
  subject(:session) { { userinfo: { info: { email: "alice@example.com" }, extra: { raw_info: { sub: "aaaa", "https://cloudnativedays.jp/roles" => roles } } } } }
  let(:roles) { [] }

  describe "GET event#show" do
    before do
      create(:cndt2020)
    end

    context "not logged in" do
      it "returns a success response with event top page" do
        get "/cndt2020"
        expect(response).to(be_successful)
        expect(response).to(have_http_status("200"))
        expect(response.body).to(include("CloudNative Days Tokyo 2020"))
        expect(response.body).to(include("\u30B9\u30D4\u30FC\u30AB\u30FC\u3068\u3057\u3066\u30A8\u30F3\u30C8\u30EA\u30FC"))
      end

      it "returns a success response with privacy policy" do
        get "/cndt2020/privacy"
        expect(response).to(be_successful)
        expect(response).to(have_http_status("200"))
        expect(response.body).to(include("This is Privacy Policy"))
      end

      it "returns a success response with code of conduct" do
        get "/cndt2020/coc"
        expect(response).to(be_successful)
        expect(response).to(have_http_status("200"))
        expect(response.body).to(include("\u884C\u52D5\u898F\u7BC4"))
      end
    end

    context "when logged in and speaker_entry is enabled" do
      context "not registered" do
        before do
          allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
        end

        it "returns a success response with event top page" do
          get "/cndt2020"
          expect(response).to(be_successful)
          expect(response).to(have_http_status("200"))
          expect(response.body).to(include('data-method="get" href="/cndt2020/speakers/guidance"'))
        end
      end

      context "registered" do
        before do
          allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
          create(:speaker_alice)
        end

        it "returns a success response with event top page" do
          get "/cndt2020"
          expect(response).to(be_successful)
          expect(response).to(have_http_status("200"))
          expect(response.body).to(include('data-method="get" href="/cndt2020/speaker_dashboard"'))
        end
      end
    end
  end

  describe "logged in and speaker_entry is disabled" do
    before do
      create(:cndt2020, :speaker_entry_disabled)
    end

    context "not registered" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
      end

      it "returns a success response with event top page" do
        get "/cndt2020"
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status("302"))
        expect(response).to(redirect_to("/cndt2020/dashboard"))
      end
    end

    context "registered" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
        create(:speaker_alice)
      end

      it "returns a success response with event top page" do
        get "/cndt2020"
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status("302"))
        expect(response).to(redirect_to("/cndt2020/dashboard"))
      end
    end
  end
end
