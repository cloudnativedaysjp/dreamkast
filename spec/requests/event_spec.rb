require 'rails_helper'

describe EventController, type: :request do
  describe "GET event#show" do
    before do
      create(:cndt2020)
    end

    describe 'not logged in' do
      it "returns a success response with event top page" do
        get '/cndt2020'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to include 'CloudNative Days Tokyo 2020'
      end
    end

    describe 'logged in and not registerd' do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "foo@example.com"}})
      end

      it "redirect to /:event/profiles/talks" do
        get '/cndt2020'
        expect(response).to_not be_successful
        expect(response).to have_http_status '302'
        expect(response).to redirect_to profiles_talks_path
      end
    end
  end
end