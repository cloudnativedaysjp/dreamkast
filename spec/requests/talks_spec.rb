require "rails_helper"

describe TalksController, type: :request do
  subject(:session) { { userinfo: { info: { email: "alice@example.com", extra: { sub: "aaa" } }, extra: { raw_info: { sub: "aaa", "https://cloudnativedays.jp/roles" => roles } } } } }
  let(:roles) { [] }

  describe "GET /cndt2020/talks/:id" do
    context "CNDT2020 is registered" do
      before do
        create(:cndt2020, :registered)
        create(:talk_category1)
        create(:talk_difficulties1)
      end
      let!(:talk1) { create(:talk1) }
      let!(:talk2) { create(:talk2) }
      let!(:video) { create(:video) }

      context "user doesn't logged in" do
        it "returns a success response" do
          get "/cndt2020/talks/1"
          expect(response).to(be_successful)
          expect(response).to(have_http_status("200"))
          expect(response.body).to(include(talk1.abstract))
          expect(response.body).to(include(talk1.title))
        end

        it "doesn't includes vimeo iframe" do
          get "/cndt2020/talks/1"
          expect(response).to(be_successful)
          expect(response.body).not_to(include("player.vimeo.com"))
        end

        it "doesn't includes slido iframe" do
          get "/cndt2020/talks/1"
          expect(response).to(be_successful)
          expect(response.body).not_to(include("sli.do"))
        end
      end

      context "user logged in" do
        context "user doesn't registered" do
          before do
            allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(userinfo: { info: { email: "alice@example.com" } }))
          end

          it "redirect to /cndt2020/registration" do
            get "/cndt2020/talks/1"
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status("302"))
            expect(response).to(redirect_to("/cndt2020/registration"))
          end
        end

        context "user already registered" do
          before do
            create(:alice, :on_cndt2020)
            allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
          end

          it "returns a success response with form" do
            get "/cndt2020/talks/2"
            expect(response).to(be_successful)
            expect(response).to(have_http_status("200"))
            expect(response.body).to(include("\u30BF\u30A4\u30E0\u30C6\u30FC\u30D6\u30EB"))
            expect(response.body).to(include(talk2.title))
          end

          it "includes slido iframe if it has slido id" do
            get "/cndt2020/talks/1"
            expect(response).to(be_successful)
            expect(response.body).to(include("sli.do"))
          end

          it "includes twitter iframe if it not have slido id" do
            get "/cndt2020/talks/2"
            expect(response).to(be_successful)
            expect(response.body).to(include("twitter-timeline"))
          end

          context "talk is archived" do
            before do
              allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
            end

            it "includes vimeo iframe" do
              get "/cndt2020/talks/1"
              expect(response).to(be_successful)
              expect(response.body).not_to(include("player.vimeo.com"))
            end
          end

          context "talk is not archived" do
            before do
              allow_any_instance_of(Talk).to(receive(:archived?).and_return(false))
            end

            it "includes vimeo iframe" do
              get "/cndt2020/talks/1"
              expect(response).to(be_successful)
              expect(response.body).not_to(include("player.vimeo.com"))
            end
          end
        end
      end
    end

    context "CNDT2020 is opened" do
      before do
        create(:cndt2020, :opened)
        create(:talk_category1)
        create(:talk_difficulties1)
      end
      let!(:talk1) { create(:talk1) }
      let!(:talk2) { create(:talk2) }
      let!(:video) { create(:video) }

      context "user doesn't logged in" do
        context "talk is archived" do
          before do
            allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          end

          it "doesn't includes vimeo iframe" do
            get "/cndt2020/talks/1"
            expect(response).to(be_successful)
            expect(response.body).not_to(include("player.vimeo.com"))
          end
        end

        context "talk is not archived" do
          before do
            allow_any_instance_of(Talk).to(receive(:archived?).and_return(false))
          end

          it "doesn't includes vimeo iframe" do
            get "/cndt2020/talks/1"
            expect(response).to(be_successful)
            expect(response.body).not_to(include("player.vimeo.com"))
          end
        end
      end

      context "user logged in" do
        context "user already registered" do
          before do
            create(:cndo2021)
            create(:alice, :on_cndt2020)
            create(:alice, :on_cndo2021)
            allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
            allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          end

          it " includes vimeo iframe if video_published is true" do
            get "/cndt2020/talks/1"
            expect(response).to(be_successful)
            expect(response.body).to(include("player.vimeo.com"))
          end

          it "doesn't includes vimeo iframe if video_published is false" do
            get "/cndt2020/talks/2"
            expect(response).to(be_successful)
            expect(response.body).not_to(include("player.vimeo.com"))
          end

          it "return 404 when you try to show talk that is not included conference" do
            get "/cndo2021/talks/1"
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status("404"))
          end

          context "talk is archived" do
            before do
              allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
            end

            it "includes vimeo iframe" do
              get "/cndt2020/talks/1"
              expect(response).to(be_successful)
              expect(response.body).to(include("player.vimeo.com"))
            end
          end

          context "talk is not archived" do
            before do
              allow_any_instance_of(Talk).to(receive(:archived?).and_return(false))
            end

            it "includes vimeo iframe" do
              get "/cndt2020/talks/1"
              expect(response).to(be_successful)
              expect(response.body).not_to(include("player.vimeo.com"))
            end
          end
        end
      end
    end

    context "CNDT2020 is closed" do
      before do
        create(:cndt2020, :closed)
        create(:talk_category1)
        create(:talk_difficulties1)
      end
      let!(:talk1) { create(:talk1) }
      let!(:talk2) { create(:talk2) }
      let!(:video) { create(:video) }

      context "user doesn't logged in" do
        describe "talk is archived" do
          before do
            allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          end

          it "includes vimeo iframe" do
            get "/cndt2020/talks/1"
            expect(response).to(be_successful)
            expect(response.body).to_not(include("player.vimeo.com"))
          end
        end

        context "talk is not archived" do
          before do
            allow_any_instance_of(Talk).to(receive(:archived?).and_return(false))
          end

          it "doesn't includes vimeo iframe" do
            get "/cndt2020/talks/1"
            expect(response).to(be_successful)
            expect(response.body).to_not(include("player.vimeo.com"))
          end
        end
      end

      context "user logged in" do
        context "user already registered" do
          before do
            create(:cndo2021)
            create(:alice, :on_cndt2020)
            create(:alice, :on_cndo2021)
            allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
            allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          end

          it " includes vimeo iframe if video_published is true" do
            get "/cndt2020/talks/1"
            expect(response).to(be_successful)
            expect(response.body).to(include("player.vimeo.com"))
          end

          it "doesn't includes vimeo iframe if video_published is false" do
            get "/cndt2020/talks/2"
            expect(response).to(be_successful)
            expect(response.body).not_to(include("player.vimeo.com"))
          end

          it "return 404 when you try to show talk that is not included conference" do
            get "/cndo2021/talks/1"
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status("404"))
          end

          context "talk is archived" do
            before do
              allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
            end

            it "includes vimeo iframe" do
              get "/cndt2020/talks/1"
              expect(response).to(be_successful)
              expect(response.body).to(include("player.vimeo.com"))
            end
          end

          context "talk is not archived" do
            before do
              allow_any_instance_of(Talk).to(receive(:archived?).and_return(false))
            end

            it "includes vimeo iframe" do
              get "/cndt2020/talks/1"
              expect(response).to(be_successful)
              expect(response.body).not_to(include("player.vimeo.com"))
            end
          end
        end
      end
    end

    context "CNDT2020 is archived" do
      before do
        create(:cndt2020, :archived)
        create(:talk_category1)
        create(:talk_difficulties1)
      end
      let!(:talk1) { create(:talk1) }
      let!(:talk2) { create(:talk2) }
      let!(:video) { create(:video) }

      context "user doesn't logged in" do
        context "talk is archived" do
          before do
            allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          end

          it "includes vimeo iframe" do
            get "/cndt2020/talks/1"
            expect(response).to(be_successful)
            expect(response.body).to(include("player.vimeo.com"))
          end
        end

        context "talk is not archived" do
          before do
            allow_any_instance_of(Talk).to(receive(:archived?).and_return(false))
          end

          it "doesn't includes vimeo iframe" do
            get "/cndt2020/talks/1"
            expect(response).to(be_successful)
            expect(response.body).to_not(include("player.vimeo.com"))
          end
        end
      end

      context "user logged in" do
        context "user already registered" do
          before do
            create(:cndo2021)
            create(:alice, :on_cndt2020)
            create(:alice, :on_cndo2021)
            allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
            allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          end

          it " includes vimeo iframe if video_published is true" do
            get "/cndt2020/talks/1"
            expect(response).to(be_successful)
            expect(response.body).to(include("player.vimeo.com"))
          end

          it "doesn't includes vimeo iframe if video_published is false" do
            get "/cndt2020/talks/2"
            expect(response).to(be_successful)
            expect(response.body).not_to(include("player.vimeo.com"))
          end

          it "return 404 when you try to show talk that is not included conference" do
            get "/cndo2021/talks/1"
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status("404"))
          end

          context "talk is archived" do
            before do
              allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
            end

            it "includes vimeo iframe" do
              get "/cndt2020/talks/1"
              expect(response).to(be_successful)
              expect(response.body).to(include("player.vimeo.com"))
            end
          end

          context "talk is not archived" do
            before do
              allow_any_instance_of(Talk).to(receive(:archived?).and_return(false))
            end

            it "includes vimeo iframe" do
              get "/cndt2020/talks/1"
              expect(response).to(be_successful)
              expect(response.body).not_to(include("player.vimeo.com"))
            end
          end
        end
      end
    end
  end

  describe "GET /cndt2020/talks" do
    let!(:userinfo) { { userinfo: { info: { email: "alice@example.com" }, extra: { raw_info: { "https://cloudnativedays.jp/roles" => "CNDT2020-Admin", sub: "" } } } } }

    context "CNDT2020 is registered" do
      before { create(:cndt2020, :registered) }

      context "user doesn't logged in" do
        it "returns a success response" do
          get "/cndt2020/talks"
          expect(response).to(be_successful)
        end
      end

      context "user doesn't registered" do
        before {
          allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(userinfo))
        }
        it "redirect to /cndt2020/registration" do
          get "/cndt2020/talks"
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status("302"))
          expect(response).to(redirect_to("/cndt2020/registration"))
        end

        context "when user is registered as speaker" do
          before { create(:speaker_alice) }
          it "returns a success response" do
            get "/cndt2020/talks"
            expect(response).to(be_successful)
          end
        end
      end
    end

    context "CNDT2020 is opened" do
      before  { create(:cndt2020, :opened) }
      context "user doesn't registered" do
        before {
          allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(userinfo))
        }
        it "redirect to /cndt2020/registration" do
          get "/cndt2020/talks"
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status("302"))
          expect(response).to(redirect_to("/cndt2020/registration"))
        end

        context "when user is registered as speaker" do
          before { create(:speaker_alice) }
          it "redirect to /cndt2020/registration" do
            get "/cndt2020/talks"
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status("302"))
            expect(response).to(redirect_to("/cndt2020/registration"))
          end
        end
      end
    end
  end
end
