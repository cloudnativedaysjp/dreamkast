require 'rails_helper'

describe Profiles::TalksController, type: :request do
  describe "GET profiles/talks#show" do
    before do
      create(:cndt2020)
    end

    describe 'not logged in' do
      it "returns a success response with event top page" do
        get '/cndt2020/profiles/talks'
        expect(response).to_not be_successful
        expect(response).to have_http_status '302'
        expect(response).to redirect_to '/cndt2020'
      end
    end

    describe 'logged in and not registerd' do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "foo@example.com"}})
      end

      it "redirect to /:event/profiles/talks" do
        get '/cndt2020/profiles/talks'
        expect(response).to_not be_successful
        expect(response).to have_http_status '302'
        expect(response).to redirect_to registration_path
      end
    end

    describe 'logged in and registerd' do
      before do
        create(:alice)
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:session).and_return(userinfo: {info: {email: "foo@example.com", extra: {sub: "aaa"}}, extra: {raw_info: {sub: "aaa"}}})
      end

      it "redirect to /:event/profiles/talks" do
        get '/cndt2020/profiles/talks'
        expect(response).to be_successful
        expect(response).to have_http_status '200'
      end
    end
  end
end