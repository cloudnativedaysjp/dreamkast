require 'rails_helper'

describe EventController, type: :request do
  describe "GET event#show" do
    before do
      create(:cndt2020)
      create(:day1)
      create(:day2)
    end

    describe 'not logged in' do
      it "returns a success response with event top page" do
        get '/cndt2020'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include 'CloudNative Days Tokyo 2020'
      end

      it "returns a success response with privacy policy" do
        get '/cndt2020/privacy'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include 'This is Privacy Policy'
      end

      it "returns a success response with code of conduct" do
        get '/cndt2020/coc'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include '行動規範'
      end
    end

    describe 'logged in and not registerd' do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "foo@example.com"}})
      end

      it "redirect to /cndt2020/registration" do
        get '/cndt2020'
        expect(response).to_not be_successful
        expect(response).to have_http_status '302'
        expect(response).to redirect_to '/cndt2020/registration'
      end
    end
  end
end