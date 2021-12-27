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
        before { create(:alice, :on_cndt2020) }

        context "user is admin" do
          let(:roles) { ["CNDT2020-Admin"] }

          context "published" do
            before { create(:speaker_announcement, :cndt2020, :published) }
            it "has 公開済み announcement" do
              subject
              expect(response).to(be_successful)
              expect(response).to(have_http_status("200"))
              expect(response.body).to(include("mike"))
              expect(response.body).to(include("公開済み"))
            end

            context "not published" do
              before { create(:speaker_announcement, :cndt2020) }
              it "has 非公開 announcement" do
                subject
                expect(response).to(be_successful)
                expect(response).to(have_http_status("200"))
                expect(response.body).to(include("mike"))
                expect(response.body).to(include("非公開"))
              end
            end
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
