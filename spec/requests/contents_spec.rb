require 'rails_helper'

describe ContentsController, type: :request do
  describe "GET #kontest" do

    describe "logged in and registered" do
      subject(:session) { {userinfo: {info: {email: "alice@example.com", extra: {sub: "alice"}}, extra: {raw_info: {sub: "alice", "https://cloudnativedays.jp/roles" => roles}}} } }
      let(:roles) { [] }

      before do
        create(:cndt2020)
        create(:alice, :on_cndt2020)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
      end

      it "returns a success response with kontest (sub event) list" do
        get '/cndt2020/kontest'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include 'https://'
      end
    end

    describe 'logged in and not registerd' do
      before do
        create(:cndt2020)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "alice@example.com"}})
      end

      it "redirect to /cndt2020/registration" do
        get '/cndt2020/kontest'
        expect(response).to_not be_successful
        expect(response).to have_http_status '302'
        expect(response).to redirect_to '/cndt2020/registration'
      end
    end

    describe "not logged in" do
      before do
        create(:cndt2020)
      end

      it "returns a success response with kontest (sub event) list" do
        get '/cndt2020/kontest'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include 'kontest'
      end
    end

  end

  describe "GET #discussion" do

    describe "logged in and registered" do
      subject(:session) { {userinfo: {info: {email: "alice@example.com", extra: {sub: "alice"}}, extra: {raw_info: {sub: "alice", "https://cloudnativedays.jp/roles" => roles}}} } }
      let(:roles) { [] }

      before do
        create(:cndt2020)
        create(:alice, :on_cndt2020)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
      end

      it "returns a success response with discussion" do
        get '/cndt2020/discussion'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include '書き込む'
      end
    end

    describe 'logged in and not registerd' do
      before do
        create(:cndt2020)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "alice@example.com"}})
      end

      it "redirect to /cndt2020/registration" do
        get '/cndt2020/discussion'
        expect(response).to_not be_successful
        expect(response).to have_http_status '302'
        expect(response).to redirect_to '/cndt2020/registration'
      end
    end

    describe "not logged in" do
      before do
        create(:cndt2020)
      end

      it "returns a success response with discussion" do
        get '/cndt2020/discussion'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include '使い方'
      end
    end

  end

end
