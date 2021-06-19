require 'rails_helper'

RSpec.describe TracksController, type: :request do
  subject(:session) { {userinfo: {info: {email: "alice@example.com", extra: {sub: "aaa"}}, extra: {raw_info: {sub: "aaa", "https://cloudnativedays.jp/roles" => roles}}} } }
  let(:roles) { [] }

  describe "GET /:event/dashboard" do
    describe "logged in and registered" do
      before do
        create(:cndt2020)
        create(:alice, :on_cndt2020)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
      end

      context "user is admin" do
        let(:roles) { ["CNDT2020-Admin"] }

        it "return a success response" do
          get '/cndt2020/dashboard'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
        end

        it "link to admin is displayed" do
          get '/cndt2020/dashboard'
          expect(response.body).to include('<a class="dropdown-item" href="/cndt2020/admin">管理画面</a>')
        end
      end

      context "user is not admin" do
        it "return a success response" do
          get '/cndt2020/dashboard'
          expect(response).to be_successful
          expect(response).to have_http_status '200'
        end

        it "link to admin is not displayed" do
          get '/cndt2020/dashboard'
          expect(response.body).to_not include('<a class="dropdown-item" href="/admin">管理画面</a>')
        end
      end

      context 'get not exists event\'s dashboard' do
        it "returns not found response" do
          get '/not_found/dashboard'
          expect(response).to_not be_successful
          expect(response).to have_http_status '404'
        end
      end
    end

    describe "not logged in" do
      before do
        create(:cndt2020)
      end

      context 'get exists event\'s dashboard' do
        it "redirect to top page a success response" do
          get '/cndt2020/dashboard'
          expect(response).to_not be_successful
          expect(response).to have_http_status '302'
          expect(response).to redirect_to '/cndt2020'
        end
      end

      context 'get not exists event\'s dashboard' do
        it "redirect to top page a success response" do
          get '/not_found/dashboard'
          expect(response).to_not be_successful
          expect(response).to have_http_status '404'
        end
      end
    end
  end

  describe "GET /:event/tracks" do
    describe "logged in and registered" do
      before do
        create(:cndt2020, :opened)
        create(:alice, :on_cndt2020)
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
          expect(response).to be_successful
          expect(response).to have_http_status '200'
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
