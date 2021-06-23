require 'rails_helper'

describe Admin::SpeakersController, type: :request do
  subject(:session) { {userinfo: {info: {email: "alice@example.com", extra: {sub: "alice"}}, extra: {raw_info: {sub: "alice", "https://cloudnativedays.jp/roles" => roles}}} } }
  let(:roles) { [] }

  before do
    create(:cndt2020)
  end

  describe "GET :event/admin/talks#index" do
    context "user doesn't logged in" do
      it "redirect to event top page" do
        get admin_talks_path(event: 'cndt2020')
        expect(response).to_not be_successful
        expect(response).to have_http_status '302'
        expect(response).to redirect_to '/cndt2020'
      end
    end

    context "user logged in" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
      end

      context "user is not registered" do
        it "redirect to //registration" do
          skip 'TODO: `//registration` にリダイレクトされて名前解決できずにエラーになるので修正が必要'
          get admin_talks_path
          expect(response).to_not be_successful
          expect(response).to have_http_status '302'
          expect(response).to redirect_to '//registration'
        end
      end

      context "user is registered" do
        before do
          create(:alice, :on_cndt2020)
        end

        context "user is admin" do
          let(:roles) { ["CNDT2020-Admin"] }

          it "returns a success response" do
            get admin_talks_path(event: 'cndt2020')
            expect(response).to be_successful
            expect(response).to have_http_status '200'
          end
        end

        context "user is not admin" do
          it "returns a success response" do
            get admin_talks_path(event: 'cndt2020')
            expect(response).to_not be_successful
            expect(response).to have_http_status '403'
          end
        end
      end
    end
  end
end