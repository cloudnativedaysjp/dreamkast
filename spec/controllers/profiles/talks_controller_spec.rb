require 'rails_helper'

RSpec.describe Profiles::TalksController, type: :controller do
  describe "GET #show" do
    describe "not logged in" do
      it "redirect to /:event" do
        post :show, params: {event: 'cndt2020'}
        expect(response).to redirect_to "http://test.host/cndt2020"
      end
    end

    describe "logged in and not registered" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "foo@example.com"}})
      end

      it "redirect to /:event/registration" do
        post :show, params: {event: 'cndt2020'}
        expect(response).to redirect_to registration_path
      end
    end

    describe "logged in and registered" do
      before do
        create(:alice)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "foo@example.com"}})
      end

      it "routes /:event/profiles/talks" do
        post :show, params: {event: 'cndt2020'}
        expect(response).to be_successful
      end
    end
  end

  describe "POST #create" do
    describe "not logged in" do
      let(:profile)  { create(:profile) }

      it "redirect to /:event" do
        post :create, params: {event: 'cndt2020'}
        expect(response).to redirect_to "http://test.host/cndt2020"
      end
    end

    describe "logged in and not registered" do
      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "foo@example.com"}})
      end

      it "redirect to /:event/registration" do
        post :create, params: {event: 'cndt2020'}
        expect(response).to redirect_to registration_path
      end
    end

    describe "logged in and registered" do
      before do
        create(:alice)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(userinfo: {info: {email: "foo@example.com"}})
      end

      it "redirect to /:event/timetables" do
        post :create, params: {event: 'cndt2020'}
        expect(response).to redirect_to timetables_path
      end
    end
  end
end