require 'rails_helper'

describe ProfilesController, type: :request do
  describe "GET /registration" do
    before do
      create(:cndt2020)
    end

    describe 'not logged in' do
      it "redirect to event top page" do
        get '/cndt2020/registration'
        expect(response).to_not be_successful
        expect(response).to have_http_status '302'
        expect(response).to redirect_to '/cndt2020'
      end
    end

    describe 'logged in and not registerd' do
      subject(:user_session) { {userinfo: {info: {email: "foo@example.com"}, extra: {raw_info: {sub: "mock", "https://cloudnativedays.jp/roles" => ""}}}}}

      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(user_session)
      end

      it "doesn't have timetable and speakers links" do
        get '/cndt2020/registration'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
        expect(response.body).to_not include 'Timetable'
      end
    end
  end
end