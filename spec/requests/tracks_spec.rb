require 'rails_helper'

RSpec.describe DashboardController, type: :request do
  subject(:session) { {userinfo: {info: {email: "foo@example.com", extra: {sub: "aaa"}}, extra: {raw_info: {sub: "aaa", "https://cloudnativedays.jp/roles" => roles}}} } }
  let(:roles) { [] }

  describe "GET /:event/tracks" do
    describe "logged in and registered" do
      before do
        create(:cndt2020_opened)
        create(:alice)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
      end

      context "when user access to dashboard" do
        it "return a success response" do
          get '/cndt2020/tracks'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
        end
      end

      context "when user access to root page" do
        it "redirect to tracks" do
          get '/cndt2020'
          expect(response).to_not be_successful
          expect(response).to have_http_status '302'
          expect(response).to redirect_to '/cndt2020/tracks'
        end
      end
    end

    describe "not logged in" do
      before do
        create(:cndt2020)
      end

      context 'get exists event\'s dashboard' do
        it "redirect to top page a success response" do
          get '/cndt2020/tracks'
          expect(response).to_not be_successful
          expect(response).to have_http_status '302'
          expect(response).to redirect_to '/cndt2020'
        end
      end
    end
  end
end
