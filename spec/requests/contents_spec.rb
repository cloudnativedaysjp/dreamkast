require 'rails_helper'

describe ContentsController, type: :request do
  describe "GET #index" do

    describe "logged in and registered" do
      subject(:session) { {userinfo: {info: {email: "foo@example.com", extra: {sub: "aaa"}}, extra: {raw_info: {sub: "aaa", "https://cloudnativedays.jp/roles" => roles}}} } }
      let(:roles) { [] }

      before do
        create(:cndt2020)
        create(:alice)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
      end

      it "returns a success response with contents (sub event) list" do
        get '/cndt2020/contents'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include 'https://'
      end
    end

    describe "not logged in" do
      before do
        create(:cndt2020)
      end

      it "returns a success response with contents (sub event) list" do
        get '/cndt2020/contents'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include '併設イベント'
      end
    end

  end

end
