require "rails_helper"

describe Admin::SpeakerAnnouncementsController, type: :request do
  let!(:session) { { userinfo: { info: { email: "alice@example.com", extra: { sub: "alice" } }, extra: { raw_info: { sub: "alice", "https://cloudnativedays.jp/roles" => roles } } } } }
  let(:roles) { [] }

  before do
    create(:cndt2020)
  end

  describe "GET :event/admin/speaker_announcements#index" do
    subject { get(admin_speaker_announcements_path(event: "cndt2020")) }
    context "user doesn't logged in" do
      it "redirect to event top page" do
        subject
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status("302"))
        expect(response).to(redirect_to("/cndt2020"))
      end
    end

    context "user logged in" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
      end

      context "user is registered" do
        before do
          create(:alice, :on_cndt2020)
          create(:speaker_announcement, :cndt2020, :published)
        end

        context "user is admin" do
          let(:roles) { ["CNDT2020-Admin"] }

          it "returns a success response" do
            subject
            expect(response).to(be_successful)
            expect(response).to(have_http_status("200"))
            expect(controller.instance_variable_get("@speaker_announcements").first.conference_id).to(eq(1))
            expect(controller.instance_variable_get("@speaker_announcements").first.speaker_names).to(eq("mike"))
          end
        end

        context "user is not admin" do
          it "returns a failed response" do
            subject
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status("403"))
          end
        end
      end
    end
  end
end
